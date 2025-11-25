# Env Handler Action

This repository contains a GitHub Action designed to configure job environments and manage secrets.

## Inputs

- `secrets`: GitHub secrets. Type: `string`.
- `script`: Specifies scripts for execution. Type: `string`. Required.

## Usage

Below is an example of how to use the `env-handler-action` in your GitHub workflows:

```yaml
name: "Configure Job Environment and Secrets"

on: [push]

jobs:
  build:
    runs-on: ubuntu-latest

    steps:
      - name: Set Environments
        uses: 2mc-org/env-handler-action@v1
        env:
          ENVIRONMENT: ${{ inputs.environment }}
        with:
          secrets: ${{ toJson(secrets) }}
          script: |
            set_env --name=ENVIRONMENT --value=${{ env.ENVIRONMENT }}
            set_env --name=ENVIRONMENT_LOWER --valueToLowerCase --value=${{ env.ENVIRONMENT }}
            set_env --name=BRANCH_NAME --value=${{ github.ref_name }}
            set_env --name=GITHUB_TOKEN --mask \
              --value="$(get_secret REPO_TOKEN || get_runner_secret REPO_TOKEN)"
            mapper --name=RUN_NUMBER --criteria=${{ env.ENVIRONMENT }} \
              DEV=$((${{ github.run_number }} + 300)) \
              PROD=${{ github.run_number }}
            mapper --name=SSH_KEY --criteria=${{ env.ENVIRONMENT }} --mask --logLines=1 \
              DEV="$(get_secret SSH_DEV_KEY || get_runner_secret SSH_DEV_KEY)" \
              PROD="$(get_secret SSH_PROD_KEY || get_runner_secret SSH_PROD_KEY)"

      - name: Handle Secret Files
        uses: 2mc-org/env-handler-action@v1
        with:
          script: |
            save_file --file=".env" --content="$(get_variable ${{ env.ENVIRONMENT }}_ENV)"
            save_env_from_file --file=".env" --name=APP_PORT --key=PORT
```

## Script Details and Usage Examples

- **get_variable**:
  Retrieves a variable from the GitHub API for a given repository using a token for authorization.

  - Parameters:
    - `variable_name`: Name of the variable to retrieve.
    - `token`: (Optional) GitHub token for authorization. Defaults to `GITHUB_TOKEN`.
  - Example:
    ```bash
    get_variable myVariable
    ```

- **get_secret**:
  Extracts the value of a secret from a JSON object representing GitHub Secrets.

  - Parameters:
    - `key`: Key of the secret to retrieve.
  - Example:
    ```bash
    get_secret SECRET_KEY
    ```

- **get_runner_secret**:
  Reads a secret from a specified file in the `/org-secrets` directory.

  - Parameters:
    - `filename`: Name of the file from which to retrieve the secret.
  - Example:
    ```bash
    get_runner_secret secretFile
    ```

- **save_env_from_file**:
  Finds the value of an environment variable in a file by the given key and sets this value as an environment variable.

  - Parameters:
    - `--file`: Name of the file.
    - `--name`: Name of the environment variable to set.
    - `--key`: Key to retrieve the value within the file.
    - `--mask`: (Optional) Mask the output value.
  - Example:
    ```bash
    save_env_from_file --file=".env" --name=MY_VAR --key=MY_KEY --mask
    ```

- **save_file**:
  Saves content to a specified file, with optional masking of the content.

  - Parameters:
    - `--file`: Name of the file to save content to.
    - `--content`: Content to write.
    - `--mask`: (Optional) Mask the content.
  - Example:
    ```bash
    save_file --file=".env" --content="This is some content" --mask
    ```

- **set_env**:
  Sets an environment variable, with support for converting the value to lowercase and optional masking.

  - Parameters:
    - `--name`: Name of the environment variable.
    - `--value`: Value of the environment variable.
    - `--valueToLowerCase`: (Optional) Convert value to lowercase.
    - `--mask`: (Optional) Mask the value.
    - `--logLines`: (Optional) Number of lines to log.
  - Example:
    ```bash
    set_env --name=MY_VAR --value="Some Value" --valueToLowerCase
    ```

- **mapper**:
  Selects a value by criteria from a provided list of parameters and sets it as an environment variable.
  - Parameters:
    - `--name`: Name of the environment variable.
    - `--mask`: (Optional) Mask the output value.
    - `--logLines`: (Optional) Number of lines to log.
    - `--criteria`: Criteria for selecting the parameter.
    - Additional parameters in the form `PARAM_NAME=VALUE`.
  - Example:
    ```bash
    mapper --name=ENV_VAR --criteria=PROD DEV=DevelopmentValue PROD=ProductionValue
    ```
