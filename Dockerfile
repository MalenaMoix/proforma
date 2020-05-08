FROM bitnami/redmine:4

RUN sudo apt-get update && sudo apt-get -y install build-essential libmariadb-dev-compat libmariadb-dev libpq-dev

COPY . /opt/bitnami/redmine/plugins/proforma

WORKDIR /opt/bitnami/redmine/plugins/proforma
RUN sudo gem install rubyXL
RUN sudo bundler install

WORKDIR /opt/bitnami/redmine
RUN sudo bundle config unset deployment
RUN sudo bundle install --no-deployment

RUN sudo touch /opt/bitnami/redmine/tmp/restart.txt

COPY file2.xlsx /opt/bitnami/redmine/public/plugin_assets/excels