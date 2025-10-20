#!/bin/sh
# Copyright (c) 2024, WSO2 LLC. (http://www.wso2.com).

# WSO2 LLC. licenses this file to you under the Apache License,
# Version 2.0 (the "License"); you may not use this file except
# in compliance with the License.
# You may obtain a copy of the License at

# http://www.apache.org/licenses/LICENSE-2.0

# Unless required by applicable law or agreed to in writing,
# software distributed under the License is distributed on an
# "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
# KIND, either express or implied.  See the License for the
# specific language governing permissions and limitations
# under the License.

set -e

echo "Starting Healthcare Call Center App..."

# Create a runtime configuration file that can be loaded by the app
cat > /usr/share/nginx/html/config.js << EOF
window.__ENV__ = {
  VITE_MPI_SERVICE_URL: "${VITE_MPI_SERVICE_URL:-http://localhost:8081}",
  VITE_DATA_AGGREGATOR_URL: "${VITE_DATA_AGGREGATOR_URL:-http://localhost:8000}",
  VITE_CALL_CENTER_AI_AGENT_URL: "${VITE_CALL_CENTER_AI_AGENT_URL:-http://localhost:9090}",
  VITE_PATIENT_MATCH_COUNT: "${VITE_PATIENT_MATCH_COUNT:-1}",
  VITE_PATIENT_MATCH_ONLY_SINGLE_MATCH: "${VITE_PATIENT_MATCH_ONLY_SINGLE_MATCH:-true}",
  VITE_PATIENT_MATCH_ONLY_CERTAIN_MATCH: "${VITE_PATIENT_MATCH_ONLY_CERTAIN_MATCH:-true}",
  VITE_REACT_APP_ASGARDEO_CLIENT_ID: "${VITE_REACT_APP_ASGARDEO_CLIENT_ID:-}",
  VITE_REACT_APP_ASGARDEO_CLIENT_SECRET: "${VITE_REACT_APP_ASGARDEO_CLIENT_SECRET:-}",
  VITE_REACT_APP_ASGARDEO_BASE_URL: "${VITE_REACT_APP_ASGARDEO_BASE_URL:-}",
  VITE_REACT_APP_REDIRECT_URL: "${VITE_REACT_APP_REDIRECT_URL:-http://localhost:8080}"
};
EOF

echo "Runtime configuration created with environment variables:"
echo "- MPI Service URL: ${VITE_MPI_SERVICE_URL:-http://localhost:8081}"
echo "- Data Aggregator URL: ${VITE_DATA_AGGREGATOR_URL:-http://localhost:8000}"
echo "- Call Center AI Agent URL: ${VITE_CALL_CENTER_AI_AGENT_URL:-http://localhost:9090}"
echo "- Asgardeo Base URL: ${VITE_REACT_APP_ASGARDEO_BASE_URL:-[not set]}"

exec "$@"