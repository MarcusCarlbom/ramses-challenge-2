# Code Challenge #2 - RAMSES

## The challenge

In this challenge, your group's UPISAS competes against a naive UPISAS. The naive UPISAS adapts only by reactively starting a new instance whenever a problem appears, such as a service slowing down, crashing or getting more load.

Your version runs on the [scenarios](#scenarios) below. Your goal is to be equal to or better than the naive UPISAS in each of them.

You need a running RAMSES setup. If you don't have one yet, follow Part 1 of [Code Challenge #1](https://github.com/MarcusCarlbom/ramses-challenge-1#part-1---set-up-ramses).

Because an external service that RAMSES's payment and delivery depend on was shut down this week, these services now have to run locally. To set this up, add the file [`start_external_services.sh`](start_external_services.sh) to the `bash_scripts/execute/` folder of your RAMSES package, and add the line `bash start_external_services.sh` to your `RUN_ALL.sh` (or `RUN_ALL_LINUX.sh`), just before `echo; PrintSuccess "DONE!"; echo`. Your config repo also needs updating, so either sync your fork of `config-server` with [MarcusCarlbom/config-server](https://github.com/MarcusCarlbom/config-server) again, or add `payment.service.uri=http://${IMPLEMENTATION_NAME}-backend:48090` to `payment-proxy-service.properties` and `delivery.service.uri=http://${IMPLEMENTATION_NAME}-backend:48090` to `delivery-proxy-service.properties`.

## Make your UPISAS

```bash
git clone https://github.com/S2-group/UPISAS
cd UPISAS
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt flask
```

You can continue in the UPISAS clone from Challenge #1. In your UPISAS clone, you need two files of your own and two you can copy.

**`interface/`** connects UPISAS to RAMSES. Copy the [`interface` folder](https://github.com/MarcusCarlbom/ramses-challenge-1/tree/main/interface). `GET /monitor` returns the state of RAMSES, and `PUT /execute` sends your adaptation. `GET /adaptation_options` lists what you can send.

**`UPISAS/exemplars/ramses.py`** points UPISAS at `http://localhost:50000` and starts the scenario with these settings. Download the image first with `docker pull`, and use your own architecture in its name.

```python
docker_config = {
    "name": "simulation-scenario",
    "image": "giamburrasca/scenario1:arm64",
    "network": "ramses-sas-net",
    "environment": {
        "ADAPT": "0",
    },
}
```

**`UPISAS/strategies/my_strategy.py`** In `analyze()`, use the monitored data to detect what is going wrong in the scenario. In `plan()`, decide how to respond. Starting a new instance is one option, but the naive UPISAS already does that for every problem.

**`run_challenge.py`** runs your strategy. Copy [`run_challenge.py`](https://github.com/MarcusCarlbom/ramses-challenge-1/blob/main/scenario/run_challenge.py), then run these in separate terminals.

```bash
python interface/interface.py
python run_challenge.py
```

## Scenarios

Your solution is evaluated on 10 scenarios of 5 minutes each. In them, one or more instances die, slow down or start failing part of their requests. The first 7 scenarios are basic problems, and the last 3 are more complex and harder to beat.

## What to submit

Commit the two files you created to your repository and submit the Github release link.

- `UPISAS/exemplars/ramses.py`
- `UPISAS/strategies/my_strategy.py`

## Evaluation

**Naive UPISAS.** The naive UPISAS is [`naive_upisas/naive_strategy.py`](naive_upisas/naive_strategy.py). It runs with `ADAPT=0`, like your own code, and reacts to every problem by starting a new instance of the affected service.

**Setup.** For each of the 10 scenarios, we run the naive UPISAS once and your solution once, each on a fresh RAMSES.

**Adaptation objective.** You are tested on the availability of `ORDERING-SERVICE` and on how much of the run its response time stays within 800 ms, and your solution must beat the naive UPISAS on both.
