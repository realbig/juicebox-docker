# juicebox-docker

Please read the README at https://github.com/d4mation/wp-docker for basic usage instructions.

---

This required a lot of rework to work properly with the Bedrock+Capistrano setup, so I wanted to put this somewhere more permanent than my own local machine.

Clone the website repository to `./juicebox` within this one.

- `cap production wpcli:db:pull WP_HOME=https://docker.test` will pull down the database and import it into the database container.
    - Warning: Unfortunately, this doesn't do _quite all_ the search-replaces necessary and I am not certain why. Going to http://docker.test:8081 and replacing example-domain.com with docker.test will finish the rest of them.
    - Swap out docker.test/wp/? with docker.test/ as well with Regex enabled
- `cap production wpcli:uploads:rsync:pull` will pull down all the Uploads on the site
- Rename `juicebox/web/app/mu-plugins` to `juicebox/web/app/mu-plugins-bak`, create an empty directory at `web/app/mu-plugins`, and then `cd` into `web/app/mu-plugins` and run `git ls-files -z | xargs -0 git update-index --assume-unchanged`
    - There's a mu-plugin on this site that screws with `ABSPATH` and we don't want that.
- You may want to rename the "Rename WP Login" plugin temporarily in order to force-deactivate it.
- You may also want to disable the SMTP plugin. While it will prevent emails being sent due to an IP Address mismatch, MailHog can't capture them with it active
    - Be sure to copy back in the MailHog mu-plugin from the Docker setup! https://github.com/d4mation/wp-docker/blob/master/wp-content/mu-plugins/mailhog.php

---

You will also need to make the following changes to the Juicebox setup (At least temporarily)

- Add the followeing to the bottom of `juicebox/config/deploy.rb`
```
# This is the local, Docker container for mySQL
# This is specific to Eric Defore's (RBM) setup
server "localhost", user: 'wp', 'password': 'password', roles: %w{dev}
set :dev_path, '~'
```
- Add the following to `juicebox/.gitignore`
```
# Specific to Eric Defore's (RBM) setup
web/app/mu-plugins/mailhog.php
web/app/mu-plugins-bak/
```
- Add the following to `juicebox/Gemfile`
```
# Support OpenSSH keys
gem 'ed25519', '>= 1.2', '< 2.0'
gem 'bcrypt_pbkdf', '>= 1.0', '< 2.0'
```
