# -*- coding: utf-8 -*-

from template import generate_cfg_from_template

template_file='snr/snr_switch_template.txt'
yaml_file='snr_data/snr_227.yaml'
#print (template_file,yaml_file)
config=generate_cfg_from_template(template_file,yaml_file)
print (config)
