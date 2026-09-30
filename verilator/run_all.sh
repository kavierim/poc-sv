#!/usr/bin/env bash
# SPDX-FileCopyrightText: 2026 Kari Vierimaa, Kempele, Finland
#
# Ancillary repository file (not Covered Source). RTL is under Apache-2.0; see NOTICE.

# Build and run every sim/**/*_tb.sv with Verilator 5.
# Run from anywhere; the script cds to the PoC_sv root.
# Exit 0 only when every test exits 0.

set -u

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

JOBS="${JOBS:-1}"
SIM_TIMEOUT="${SIM_TIMEOUT:-120}"
pass=0
fail=0
declare -a failed_names=()

if ! command -v verilator >/dev/null 2>&1; then
  echo "verilator is not on PATH" >&2
  exit 1
fi

if ! command -v timeout >/dev/null 2>&1; then
  echo "timeout(1) is not on PATH (required for sim hang protection)" >&2
  exit 1
fi

# Drop stale Verilator sim binaries left from interrupted runs (common under WSL).
stale_pids="$(pgrep -f 'obj_dir/[^/]+/V[a-zA-Z0-9_]+$' 2>/dev/null || true)"
if [[ -n "$stale_pids" ]]; then
  echo "Killing stale sim process(es): $stale_pids"
  kill -TERM $stale_pids 2>/dev/null || true
  sleep 1
  stale_pids="$(pgrep -f 'obj_dir/[^/]+/V[a-zA-Z0-9_]+$' 2>/dev/null || true)"
  if [[ -n "$stale_pids" ]]; then
    kill -KILL $stale_pids 2>/dev/null || true
  fi
fi

mapfile -t tests < <(find sim -type f -name '*_tb.sv' | sort)
if (( ${#tests[@]} == 0 )); then
  echo "no testbenches found under sim/" >&2
  exit 1
fi

lists_for() {
  local tb="$1"
  case "$tb" in
    sim/bus/axi4lite/axi4lite_DeMux_tb.sv)
      echo verilator/files/sim_bus_axi4lite_demux.f
      ;;
    sim/bus/axi4lite/*)
      echo verilator/files/sim_bus_axi4lite.f
      ;;
    sim/bus/axi4/*)
      echo verilator/files/sim_bus_axi4.f
      ;;
    sim/bus/axi4stream/*)
      echo verilator/files/sim_bus_axi4stream.f
      ;;
    sim/fifo/*)
      echo verilator/files/sim_fifo.f
      ;;
    sim/sync/*)
      echo verilator/files/sim_sync.f
      ;;
    sim/arith/*)
      echo verilator/files/sim_arith.f
      ;;
    sim/mem/*)
      echo verilator/files/sim_mem.f
      ;;
    *)
      echo "UNKNOWN"
      ;;
  esac
}

run_one() {
  local tb="$1"
  local top log
  local -a lists=() cmd=()
  top="$(basename "$tb" .sv)"
  log="obj_dir/${top}/run.log"
  mkdir -p "obj_dir/${top}"

  read -r -a lists <<< "$(lists_for "$tb")"
  if [[ "${lists[0]}" == "UNKNOWN" ]]; then
    echo "no file list for ${tb}" >"$log"
    echo FAIL >"obj_dir/${top}/result"
    return 1
  fi

  cmd=(
    verilator --timing --binary --assert
    -Wno-DECLFILENAME -Wno-MULTITOP -Wno-UNOPTFLAT
    -Wno-WIDTHEXPAND -Wno-WIDTHTRUNC -Wno-PINMISSING -Wno-ASCRANGE
    -j 1
    --Mdir "obj_dir/${top}"
    --top "$top"
    +incdir+src
    +incdir+src/bus
  )
  local list
  for list in "${lists[@]}"; do
    cmd+=(-f "$list")
  done
  cmd+=("$tb")

  {
    printf 'CMD'
    printf ' %q' "${cmd[@]}"
    printf '\n'
    "${cmd[@]}"
  } >"$log" 2>&1 || {
    echo FAIL >"obj_dir/${top}/result"
    return 1
  }

  if [[ ! -x "obj_dir/${top}/V${top}" ]]; then
    echo "missing binary obj_dir/${top}/V${top}" >>"$log"
    echo FAIL >"obj_dir/${top}/result"
    return 1
  fi

  local sim_rc=0
  timeout "$SIM_TIMEOUT" "./obj_dir/${top}/V${top}" >>"$log" 2>&1 || sim_rc=$?
  if (( sim_rc == 0 )); then
    echo PASS >"obj_dir/${top}/result"
    return 0
  fi
  if (( sim_rc == 124 )); then
    echo "simulation timed out after ${SIM_TIMEOUT}s" >>"$log"
    echo TIMEOUT >"obj_dir/${top}/result"
    return 1
  fi
  echo FAIL >"obj_dir/${top}/result"
  return 1
}

mkdir -p obj_dir
echo "Running ${#tests[@]} testbenches with ${JOBS} jobs (sim timeout ${SIM_TIMEOUT}s)"

declare -a pids=()
declare -a names=()

reap_one() {
  local pid="" i="" name=""
  wait -n || true
  for i in "${!pids[@]}"; do
    pid="${pids[i]}"
    if ! kill -0 "$pid" 2>/dev/null; then
      name="${names[i]}"
      unset 'pids[i]'
      unset 'names[i]'
      if (( ${#pids[@]} > 0 )); then
        pids=("${pids[@]}")
        names=("${names[@]}")
      else
        pids=()
        names=()
      fi
      if [[ -f "obj_dir/${name}/result" ]] && [[ "$(cat "obj_dir/${name}/result")" == PASS ]]; then
        echo "PASS ${name}"
        pass=$((pass + 1))
      elif [[ -f "obj_dir/${name}/result" ]] && [[ "$(cat "obj_dir/${name}/result")" == TIMEOUT ]]; then
        echo "FAIL ${name} (TIMEOUT)"
        fail=$((fail + 1))
        failed_names+=("$name")
        if [[ -f "obj_dir/${name}/run.log" ]]; then
          echo "----- ${name} (last 40 lines) -----"
          tail -n 40 "obj_dir/${name}/run.log"
          echo "----- end ${name} -----"
        fi
      else
        echo "FAIL ${name}"
        fail=$((fail + 1))
        failed_names+=("$name")
        if [[ -f "obj_dir/${name}/run.log" ]]; then
          echo "----- ${name} (last 40 lines) -----"
          tail -n 40 "obj_dir/${name}/run.log"
          echo "----- end ${name} -----"
        fi
      fi
      return 0
    fi
  done
  echo "reap_one: wait returned but every job is still alive" >&2
  return 0
}

for tb in "${tests[@]}"; do
  run_one "$tb" &
  pids+=("$!")
  names+=("$(basename "$tb" .sv)")
  if (( ${#pids[@]} >= JOBS )); then
    reap_one
  fi
done

while (( ${#pids[@]} > 0 )); do
  reap_one
done

echo
echo "Summary: ${pass} passed, ${fail} failed, $((pass + fail)) total"
if (( fail > 0 )); then
  echo "Failed:"
  printf '  %s\n' "${failed_names[@]}"
  exit 1
fi
exit 0
