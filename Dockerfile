# using image that includes python 3.6  and node 9.11.1
FROM gabrielfalcao/alpine37-python3-node9111

#              _   _                       _ _       _
#             | | | |                     | (_)     (_)
#  _ __  _   _| |_| |__   ___  _ __    ___| |_ _ __  _  ___
# | '_ \| | | | __| '_ \ / _ \| '_ \  / __| | | '_ \| |/ __|
# | |_) | |_| | |_| | | | (_) | | | || (__| | | | | | | (__
# | .__/ \__, |\__|_| |_|\___/|_| |_(_)___|_|_|_| |_|_|\___|
# | |     __/ |
# |_|    |___/

LABEL maintainer="Gabriel Falcão"

EXPOSE  80

VOLUME ["/partner-codes/databases", "/partner-codes/logs"]


ENV PYTHONPATH       /partner-codes/src:$PYTHONPATH

ENV PARTNER_CODES_LOGLEVEL                       DEBUG
ENV PARTNER_CODES_CONF_PATH                      /partner-codes./config/partner-codes.yaml
ENV PARTNER_CODES_GENERATE_DOCS                  true

RUN mkdir -p \
    /partner-codes/config \
    /partner-codes/databases \
    /partner-codes/logs \
    /partner-codes/src

WORKDIR /partner-codes/src
COPY . /partner-codes/src

RUN cp -f /partner-codes/src/container/config/* /partner-codes/config/
RUN pipenv install --skip-lock --dev -r development.txt
RUN pipenv install --skip-lock -r requirements.txt
RUN pipenv run python setup.py install

RUN find /partner-codes/src/container/fs -exec touch {} \; && rsync -putavoz /partner-codes/src/container/fs/ /

CMD gunicorn -c /partner-codes/config/gunicorn.conf -b 0.0.0.0:80 partner_codes:application

ENTRYPOINT ["pipenv", "run"]
