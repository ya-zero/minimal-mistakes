# -*- coding: utf-8 -*-
from jinja2 import Environment, FileSystemLoader
import yaml
import sys
import os

#$ python cfg_gen.py templates/for.txt data_files/for.yml
def generate_cfg_from_template(template_f,yaml_f):
 TEMPLATE_DIR, template_file = os.path.split(template_f)
 VARS_FILE = yaml_f

 env = Environment(
    loader=FileSystemLoader(TEMPLATE_DIR),
    trim_blocks=True,
    lstrip_blocks=True)
 template = env.get_template(template_file)

 vars_dict = yaml.load(open(VARS_FILE))

 return template.render(vars_dict)
