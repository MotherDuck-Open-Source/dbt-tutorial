---
jupytext:
  formats: md:myst
  text_representation:
    extension: .md
    format_name: myst
    format_version: 0.13
    jupytext_version: 1.11.5
kernelspec:
  display_name: Python 3
  language: python
  name: python3
---

# Setup instructions

To get started with the tutorial, we recommend a GitHub Codespace. The template can be found at [MotherDuck-Open-Source/dbt-tutorial-template](https://github.com/MotherDuck-Open-Source/dbt-tutorial-template).

If you feel like using your own local environment or another IDE, take a look at the [`Makefile`](https://github.com/MotherDuck-Open-Source/dbt-tutorial-template/blob/main/Makefile) in the template repo.

For extra support, please join us at [slack.motherduck.com](https://slack.motherduck.com) in the [#smalldata-2024 channel](https://motherduckcommunity.slack.com/archives/C07N7EDJL3H).

## Getting Started with Codespaces

1. Create a MotherDuck account.
2. Fork the [`dbt-tutorial-template`](https://github.com/MotherDuck-Open-Source/dbt-tutorial-template) repo in GitHub.
3. [Generate an access token inside of MotherDuck](https://motherduck.com/docs/key-tasks/authenticating-and-connecting-to-motherduck/authenticating-to-motherduck/#authentication-using-an-access-token) and [add it as a codespace secret inside of GitHub](https://docs.github.com/en/enterprise-cloud@latest/codespaces/managing-codespaces-for-your-organization/managing-development-environment-secrets-for-your-repository-or-organization#adding-secrets-for-a-repository).
    - note: it is important that this token is called `MOTHERDUCK_TOKEN` so that it can be read by the MotherDuck DuckDB extension.
4. Open a codespace on your forked repo by clicking the big green "code" button your repo.
    - note: codespaces do not work on Safari. Use Chrome, Edge or Visual Studio Code.
5. After it loads completely, _reload the window_ in order to make sure the dbt power user extension has access to your md environment.
    - python dependencies are added in a post create hook, and the default 2-core codespace is quite slow.
6. run `dbt init` to create your dbt project. Create a new project called `my_project`, or use your preferred name.
7. Navigate to the folder created in step 7 (e.g. `my_project`) and add this `profiles.yml` file. This will be the folder that create in the previous step.

    ```yml
    # replace "my_project" with the name that matches the project name in step 6.
    my_project:
      outputs:
        dev:
          type: duckdb
          schema: main
          path: md:my_db
          threads: 1
        local:
          type: duckdb
          schema: main
          path: local.duckdb
          threads: 1
      target: dev
    ```
8.  run `dbt debug` to validate that your setup is correct.
    - note: you will need to be in the same directory as your `dbt_project.yml` file.

## Alternative setup

If you are feeling adventurous, you can run this same tutorial on your own laptop. At a minimum, you will need the libraries described in the `requirements.txt` in the [dbt-tutorial](https://github.com/MotherDuck-Open-Source/dbt-tutorial-template). After completing your environment set up (don't forget to use a venv), run `dbt init`.

_In order for `dbt power user` vscode extension to work properly with MotherDuck, you need to add your `MOTHERDUCK_TOKEN` to your environment._

### Adding a Token to Your Environment Variables

#### macOS

1. Open the **Terminal**.
2. Edit your shell profile:
   - If you're using `bash` (default in older versions of macOS), run:
     ```bash
     nano ~/.bash_profile
     ```
   - If you're using `zsh` (default in macOS Catalina and later), run:
     ```bash
     nano ~/.zshrc
     ```
3. Add the following line to the file:
   ```bash
   export API_TOKEN="your_token_value"
   ```

#### Windows
1. Press `Win + S` and search for **Environment Variables**.
2. Select **Edit the system environment variables**.
3. In the **System Properties** window, click on **Environment Variables**.
4. In the **User variables** or **System variables** section, click **New**.
5. In the **New Variable** dialog:
   - Enter the variable name (e.g., `API_TOKEN`).
   - Enter the token value (e.g., `your_token_value`).
6. Click **OK** to close all windows.
7. To verify, open a **Command Prompt** and type:
   ```bash
   echo %API_TOKEN%
   ```

#### Linux

Its probably better for you to write this tutorial than for me.
