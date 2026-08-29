# LIMEN-TED GitHub Runner v0.1

Repository-ready package for executing the six predeclared LIMEN-TED Tier-A
candidate pairs against the official TED eForms SDK 1.13.3 validation stack.

## Scientific status before execution

**6 READY / 0 FROZEN**

This repository does not change the benchmark, expected targets, or freeze
criteria. It only executes the already predeclared experiment.

## How to run on GitHub

1. Create a new GitHub repository.
2. Upload **all files and folders from this package to the repository root**.
3. Commit the files.
4. Open the repository's **Actions** tab.
5. Select **LIMEN TED full-stack execution**.
6. Click **Run workflow**.
7. When the job finishes, download the artifact named:

`LIMEN_TED_EXECUTION_RECEIPT`

The downloaded artifact contains:

`LIMEN_TED_EXECUTION_RECEIPT.zip`

Return that ZIP for promotion-gate analysis.

## What GitHub Actions does

The workflow:

1. builds the supplied Docker image;
2. installs/uses Maven + Java inside the container;
3. downloads the official OP-TED eForms SDK tag 1.13.3;
4. generates the six predeclared valid/mutant pairs;
5. runs `complete-validation.sch` with phase `eforms-16`;
6. captures SVRL;
7. applies the previously frozen receipt verifier;
8. packages XML, SVRL, environment metadata and SHA-256 hashes.

## Freeze criteria

A pair freezes only when:

- valid baseline blocking ERROR = 0;
- mutant target ERROR >= 1;
- mutant unexpected ERROR = 0;
- receipt verifier accepts the pair.

No manual override and no post-hoc repair are permitted.

## Expected output

`LIMEN_TED_EXECUTION_RECEIPT.zip`

This output is evidence of execution. It does not by itself alter the
predeclared Promotion Gate.
