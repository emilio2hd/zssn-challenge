#!/bin/bash
set -e

bundle exec rake db:migrate

rails server -b 0.0.0.0