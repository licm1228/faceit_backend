import axios from "axios";
import { feedback } from "@/stores/useFeedbackStore";

import { storage } from "@/utils/storage";

const API_BASE_URL = import.meta.env.VITE_API_BASE_URL || "";

export const api = axios.create({
  baseURL: API_BASE_URL,
  timeout: 60000
});

export function setAuthToken(token: string | null) {
  if (token) {
    api.defaults.headers.common.Authorization = token;
  } else {
    delete api.defaults.headers.common.Authorization;
  }
}

api.interceptors.request.use((config) => {
  const token = storage.getToken();
  if (token) {
    config.headers.Authorization = token;
  }
  return config;
});

api.interceptors.response.use(
  (response) => {
    const payload = response.data;
    if (payload && typeof payload === "object" && "code" in payload) {
      const code = payload.code;
      const isSuccess = code === "0" || code === 0 || code === 200 || code === "200";
      if (!isSuccess) {
        const message = payload.message || "请求失败";
        const isAuthExpired = typeof message === "string" && message.includes("未登录");
        if (isAuthExpired) {
          storage.clearAuth();
          if (window.location.pathname !== "/login") {
            window.location.href = "/login";
          }
        }
        return Promise.reject(new Error(message));
      }
      return payload.data;
    }
    return payload;
  },
  (error) => {
    if (error?.response?.status === 401) {
      storage.clearAuth();
      if (window.location.pathname !== "/login") {
        window.location.href = "/login";
      }
    }
    const responseData = error?.response?.data;
    if (responseData && typeof responseData === "object" && "message" in responseData && responseData.message) {
      feedback.error(responseData.message);
    } else if (error?.code === "ERR_NETWORK") {
      feedback.error("网络错误，请检查网络连接");
    } else {
      feedback.error(error?.message || "网络错误");
    }
    return Promise.reject(error);
  }
);
