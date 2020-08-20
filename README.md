# Deploy workspace folder to repo

Brief description:
> This action pushes a folder with files generated during the workflow run to another Github repository. It creates a new commit in the target repository containing the specified folder.

Consider this action if this matches your use case:
* your source and target are **different** repositories
* you can build your code before on previous workflow steps
* you need to release a new build in the target repository when code in your source repository changes

## Example usage

```yml
name: Build and Release
on: [push]
jobs:
  build-and-deploy:
    runs-on: ubuntu-latest

    strategy:
      matrix:
        node-version: [10.x]

    steps:
    - uses: actions/checkout@v1
    - name: Use Node.js ${{ matrix.node-version }}
      uses: actions/setup-node@v1
      with:
        node-version: ${{ matrix.node-version }}
    - name: npm install, build
      run: |
        npm install
        npm run build
    - name: Release build
      uses: hpcodecraft/action-deploy-workspace-to-repo@v2.2
      env:
        GITHUB_ACCESS_TOKEN: ${{ secrets.GITHUB_ACCESS_TOKEN }}
        SRC_FOLDER: dist
        DEST_OWNER: hpcodecraft
        DEST_REPO: hpcodecraft.github.io
        DEST_BRANCH: master
        DEST_FOLDER: docs
        DEST_PREDEPLOY_CLEANUP: "rm bundle* && rm index.html"
```

## Configuration

The `env` portion of the workflow **must** be configured before the action will work. See the example above for the syntax. Any `secrets` must be referenced using the bracket syntax and stored in the GitHub repositories `Settings/Secrets` menu. You can learn more about setting environment variables with GitHub actions [here](https://help.github.com/en/articles/workflow-syntax-for-github-actions#jobsjob_idstepsenv).

Here is a list of all the `env` options and their meaning:

| `env` variable  | description | type |
| --------------- | ----------- | ------------- |
| `GITHUB_ACCESS_TOKEN`  | In order to commit new release build of your page you must provide the action with a GitHub personal access token with read/write permissions. You can [learn more about how to generate one here](https://help.github.com/en/articles/creating-a-personal-access-token-for-the-command-line). This **should be stored as a secret.**  | `secrets` |
| `SRC_FOLDER`  | The folder in your repository that you want to deploy. If your build script compiles into a directory named `build` you'd put it here. | `env` |
| `DEST_OWNER`  | Name of GitHub user owning target repository. | `env` |
| `DEST_REPO`  | Just name of your target repository. | `env` |
| `DEST_BRANCH`  | The branch on target repo you wish to release to, for example `master`.  | `env` |
| `DEST_FOLDER`  | The folder on target repo you wish to release to, for example `docs`.  | `env` |
| `DEST_PREDEPLOY_CLEANUP`  | Cleanup shell script to remove files from target repo which are going to be replaced. It runs inside of Docker container which powers the action to run simple bash commands.  | `env` |


This action is a modification of [igolopolosov/github-action-release-github-pages](https://github.com/igolopolosov/github-action-release-github-pages)
