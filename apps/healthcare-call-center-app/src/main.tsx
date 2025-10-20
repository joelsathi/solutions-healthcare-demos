// Copyright (c) 2024, WSO2 LLC. (http://www.wso2.com).
//
// WSO2 LLC. licenses this file to you under the Apache License,
// Version 2.0 (the "License"); you may not use this file except
// in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License.

import { createRoot } from "react-dom/client";
import App from "./App.tsx";
import "./index.css";
import { StrictMode } from "react";
import { AuthProvider } from "@asgardeo/auth-react";
import { config } from "./config/runtime-config";

const authConfig = {
  signInRedirectURL: config.asgardeo.redirectUrl || window.location.origin,
  signOutRedirectURL: config.asgardeo.redirectUrl || window.location.origin,
  clientID: config.asgardeo.clientId,
  clientSecret: config.asgardeo.clientSecret,
  baseUrl: config.asgardeo.baseUrl,
  scope: ["openid", "profile", "email", "patient.read"],
  grantType: "client_credentials",
  enablePKCE: true,
  storage: "sessionStorage" as const
};

createRoot(document.getElementById("root")!).render(
  <StrictMode>
    <AuthProvider config={authConfig}>
      <App />
    </AuthProvider>
  </StrictMode>
);
