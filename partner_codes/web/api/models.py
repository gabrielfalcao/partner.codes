# -*- coding: utf-8 -*-
from partner_codes.helpers import fake
from partner_codes.web.server import api
from partner_codes.web.schemas import from_file, schema_parser


class requests:
    class v1:
        project = schema_parser(
            from_file('api/v1/request/project.json'),
            default={
                "name": fake.project_name(),
                "author": 'partner-codes',
            }
        )


class responses:
    class v1:
        project = api.schema_model(
            'project',
            from_file('api/v1/response/project.json'),
        )
        error = api.schema_model(
            'error',
            from_file('api/v1/response/error.json'),
        )
