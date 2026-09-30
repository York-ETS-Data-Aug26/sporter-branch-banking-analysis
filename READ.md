# Banking Analysis

## Setup
> It would be useful to have
> 
> - Docker
> - IDE
> - Imports (Command to run down below)


```commandline
pip install --upgrade pip           

pip install "psycopg[binary,pool]"

```

You're going to make sure you're in the project by checking
your current path. If you're not you're going to change directories
by cd into the project. The last bit of your path should look like below:

```
\sporter-branch-banking-analysis
```

Next, you're going to run the following command. This command is to start the
database connection:

```
docker compose up
```