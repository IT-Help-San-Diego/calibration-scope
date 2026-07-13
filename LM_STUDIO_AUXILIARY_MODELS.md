# LM Studio Auxiliary Model Issue

## Problem
Hermes Desktop automatically loads `ibm/granite-3.2-8b` into LM Studio without user action. The cause is `~/.hermes/config.yaml` assignments:

```yaml
background_review:
  provider: lmstudio
  model: ibm/granite-3.2-8b
moa_reference:
  provider: lmstudio
  model: ibm/granite-3.2-8b
```

## Fix Applied
Changed auxiliary assignments to cloud `stepfun/step-3.7-flash:free`:

```yaml
background_review:
  provider: stepfun
  model: stepfun/step-3.7-flash:free
moa_reference:
  provider: stepfun
  model: stepfun/step-3.7-flash:free
```

Also disabled `privacy_curator` LM Studio local mode during cleanup.

## Backup
Config backup: `~/.hermes/config.yaml.bak.granite-to-cloud-YYYYMMDD_HHMMSS`

## User Communication
This same issue will affect new Hermes Desktop setups with LM Studio provider assignments. Recommend documenting:
- Hermes loads LM Studio models on demand for auxiliary tasks
- Users should check `~/.hermes/config.yaml` for unintended LM Studio assignments
