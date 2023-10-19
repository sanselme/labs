# Copyright (c) 2023 Schubert Anselme <schubert@anselm.es>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program. If not, see <https://www.gnu.org/licenses/>.

ARG BASE_IMAGE=ubuntu:22.04
FROM ${BASE_IMAGE}

COPY . /src/labs/
RUN /src/labs/scripts/setup-machine.sh && \
  /src/labs/tools/bottle/clos.sh && \
  /src/labs/tools/bottle/inception.sh && \
  /src/labs/tools/bottle/cleanup.sh

# Make use of stopsignal (instead of sigterm) to stop systemd containers.
STOPSIGNAL SIGRTMIN+3

EXPOSE 80 443 5420 5443 6443 8200

# Initalize systemd
CMD ["/bin/bash", "-c", "exec /sbin/init --log-target=console 3>&1"]
