# Python 虚拟环境


## venv


创建虚拟环境

```shell
python -m venv [name]
```


一般 `[name]` 为 `.venv` 或 `venv` 或 `项目名称`


```shell
python -m venv .venv
```

激活环境

```shell
source [name]/bin/activate
```

## pyenv


[GitHub - pyenv/pyenv: Simple Python version management](https://github.com/pyenv/pyenv)

### Switch between Python versions

[](https://github.com/pyenv/pyenv#switch-between-python-versions)

To select a Pyenv-installed Python as the version to use, run one of the following commands:

- [`pyenv shell <version>`](https://github.com/pyenv/pyenv/blob/master/COMMANDS.md#pyenv-shell) -- select just for current shell session
- [`pyenv local <version>`](https://github.com/pyenv/pyenv/blob/master/COMMANDS.md#pyenv-local) -- automatically select whenever you are in the current directory (or its subdirectories)
- [`pyenv global <version>`](https://github.com/pyenv/pyenv/blob/master/COMMANDS.md#pyenv-shell) -- select globally for your user account

E.g. to select the above-mentioned newly-installed Python 3.10.4 as your preferred version to use:

```shell
pyenv global 3.10.4
```

Now whenever you invoke `python`, `pip` etc., an executable from the Pyenv-provided 3.10.4 installation will be run instead of the system Python.

Using "`system`" as a version name would reset the selection to your system-provided Python.



## conda


