# Copyright 2014,2015,2016,2017,2018 Security Onion Solutions, LLC

#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.

{% set masterproxy = salt['pillar.get']('static:masterupdate', '0') %}

{% if masterproxy == 1 %}

socore_own_saltstack:
  file.directory:
    - name: /opt/so/saltstack
    - user: socore
    - group: socore
    - recurse:
      - user
      - group

# Create the directories for apt-cacher-ng
aptcacherconfdir:
  file.directory:
    - name: /opt/so/conf/aptcacher-ng/etc
    - user: 939
    - group: 939
    - makedirs: True

aptcachercachedir:
  file.directory:
    - name: /opt/so/conf/aptcacher-ng/cache
    - user: 939
    - group: 939
    - makedirs: True

aptcacherlogdir:
  file.directory:
    - name: /opt/so/log/aptcacher-ng
    - user: 939
    - group: 939
    - makedirs: true

# Copy the config

acngcopyconf:
  file.managed:
    - name: /opt/so/conf/aptcacher-ng/etc/acng.conf
    - source: salt://master/files/acng/acng.conf

so-acngimage:
 cmd.run:
   - name: docker pull --disable-content-trust=false docker.io/soshybridhunter/so-acng:HH1.1.0

# Install the apt-cacher-ng container
so-aptcacherng:
  docker_container.running:
    - require:
      - so-acngimage
    - image: docker.io/soshybridhunter/so-acng:HH1.1.0
    - hostname: so-acng
    - port_bindings:
      - 0.0.0.0:3142:3142
    - binds:
      - /opt/so/conf/aptcacher-ng/cache:/var/cache/apt-cacher-ng:rw
      - /opt/so/log/aptcacher-ng:/var/log/apt-cacher-ng:rw
      - /opt/so/conf/aptcacher-ng/etc/acng.conf:/etc/apt-cacher-ng/acng.conf:ro

{% endif %}
