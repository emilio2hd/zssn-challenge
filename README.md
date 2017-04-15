ZSSN (Zombie Survival Social Network)
=====================================
[![build status](https://gitlab.com/emilio2hd/zssn/badges/master/build.svg)](https://gitlab.com/emilio2hd/zssn/commits/master)

# Getting started

Before start the application, execute:
```
bundle exec rake db:create
bundle exec rake db:migrate
bundle exec rake db:seed
```

Now, you can run the application ;)

# API Documentation
The documentation can be found at **doc** folder, or running the application and browsing http://0.0.0.0:3000

To generate the documentation, execute on terminal:
```
rake apipie:static
```