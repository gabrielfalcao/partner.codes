# -*- coding: utf-8 -*-
# import jwt
# import pyotp
import uuid

from flask_restplus.utils import merge

from partner_codes.util import slugify
from partner_codes.web.controllers import Controller
from partner_codes.logs import get_logger


logger = get_logger(__name__)


def generate_uuid():
    return str(uuid.uuid4())


class ProjectController(Controller):
    """Handles all data persistence and transformation for managing
    projects.
    """

    def create_project(self, name, author, **data):
        slug = slugify(name)
        return merge(data, {'uuid': generate_uuid(), 'name': slug, 'author': author, 'web_page_url': f'https://partner.codes/projects/{slug}'})

    def edit_project(self, uuid, **data):
        name = data.pop('name')
        slug = slugify(name)
        return merge({'uuid': uuid, 'name': slug, 'web_page_url': f'https://partner.codes/projects/{slug}'}, data)

    def delete_project(self, uuid):
        return {'uuid': uuid}

    def retrieve_project(self, uuid):
        return merge({'uuid': uuid})

    def list_projects(self, page_size=15):
        return [self.create_project(name=f"test-{i}", author=f"{i}author{i}") for i in range(page_size)]
