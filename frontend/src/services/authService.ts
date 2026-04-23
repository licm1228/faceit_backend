import { api } from "@/services/api";
import type { CurrentUser, User } from "@/types";

export interface LoginResponse extends User {}
export interface CurrentUserResponse extends CurrentUser {}

export async function login(
  username: string,
  password: string
): Promise<LoginResponse> {
  return api.post<LoginResponse, LoginResponse>("/auth/login", {
    username,
    password,
  });
}

export async function register(
  username: string,
  password: string
): Promise<LoginResponse> {
  return api.post<LoginResponse, LoginResponse>("/auth/register", {
    username,
    password,
  });
}

export async function logout(): Promise<void> {
  return api.post<void, void>("/auth/logout");
}

export async function getCurrentUser(): Promise<CurrentUserResponse> {
  return api.get<CurrentUserResponse, CurrentUserResponse>("/user/me");
}
