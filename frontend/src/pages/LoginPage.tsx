import * as React from "react";
import { useLocation, useNavigate, useSearchParams } from "react-router-dom";

import "@/styles/login-template.css";
import { useAuthStore } from "@/stores/authStore";

export function LoginPage() {
  const location = useLocation();
  const navigate = useNavigate();
  const [searchParams, setSearchParams] = useSearchParams();
  const { login, register, isLoading } = useAuthStore();
  const registerMode = searchParams.get("mode") === "register";
  const [active, setActive] = React.useState(registerMode);
  const [loginForm, setLoginForm] = React.useState({ username: "admin", password: "admin" });
  const [registerForm, setRegisterForm] = React.useState({ username: "", password: "" });
  const [loginError, setLoginError] = React.useState<string | null>(null);
  const [registerError, setRegisterError] = React.useState<string | null>(null);
  const redirectState = location.state as { redirectTo?: string; redirectState?: unknown } | null;
  const redirectTo = redirectState?.redirectTo || "/chat";

  React.useEffect(() => {
    setActive(registerMode);
  }, [registerMode]);

  const handleLoginSubmit = async (event: React.FormEvent<HTMLFormElement>) => {
    event.preventDefault();
    setLoginError(null);
    if (!loginForm.username.trim() || !loginForm.password.trim()) {
      setLoginError("Please enter your username and password.");
      return;
    }

    try {
      await login(loginForm.username.trim(), loginForm.password.trim());
      navigate(redirectTo, { state: redirectState?.redirectState });
    } catch (error) {
      setLoginError((error as Error).message || "Login failed. Please try again.");
    }
  };

  const handleRegisterSubmit = async (event: React.FormEvent<HTMLFormElement>) => {
    event.preventDefault();
    setRegisterError(null);
    if (!registerForm.username.trim() || !registerForm.password.trim()) {
      setRegisterError("Please enter a username and password.");
      return;
    }

    try {
      await register(registerForm.username.trim(), registerForm.password.trim());
      navigate(redirectTo, { state: redirectState?.redirectState });
    } catch (error) {
      setRegisterError((error as Error).message || "Sign up failed. Please try again.");
    }
  };

  return (
    <div className="auth-template-page">
      <div className={`container${active ? " active" : ""}`}>
        <div className="form-box login">
          <form onSubmit={handleLoginSubmit}>
            <h1>Login</h1>
            <div className="input-box">
              <input
                type="text"
                placeholder="Username"
                required
                value={loginForm.username}
                onChange={(event) => setLoginForm((prev) => ({ ...prev, username: event.target.value }))}
                autoComplete="username"
              />
              <i className="bx bxs-user" />
            </div>
            <div className="input-box">
              <input
                type="password"
                placeholder="Password"
                required
                value={loginForm.password}
                onChange={(event) => setLoginForm((prev) => ({ ...prev, password: event.target.value }))}
                autoComplete="current-password"
              />
              <i className="bx bxs-lock-alt" />
            </div>
            <div className="forgot-link">
              <span>Sign in to continue with Face It</span>
            </div>
            {loginError ? <p className="form-message error">{loginError}</p> : null}
            <button type="submit" className="btn" disabled={isLoading && !active}>
              {isLoading && !active ? "Signing in..." : "Login"}
            </button>
            <p>or continue with</p>
            <div className="social-icons">
              <a href="#" onClick={(event) => event.preventDefault()} aria-label="Google">
                <i className="bx bxl-google" />
              </a>
              <a href="#" onClick={(event) => event.preventDefault()} aria-label="Facebook">
                <i className="bx bxl-facebook" />
              </a>
              <a href="#" onClick={(event) => event.preventDefault()} aria-label="Github">
                <i className="bx bxl-github" />
              </a>
              <a href="#" onClick={(event) => event.preventDefault()} aria-label="LinkedIn">
                <i className="bx bxl-linkedin" />
              </a>
            </div>
          </form>
        </div>

        <div className="form-box register">
          <form onSubmit={handleRegisterSubmit}>
            <h1>Sign Up</h1>
            <div className="input-box">
              <input
                type="text"
                placeholder="Username"
                required
                value={registerForm.username}
                onChange={(event) => setRegisterForm((prev) => ({ ...prev, username: event.target.value }))}
                autoComplete="username"
              />
              <i className="bx bxs-user" />
            </div>
            <div className="input-box">
              <input
                type="password"
                placeholder="Password"
                required
                value={registerForm.password}
                onChange={(event) => setRegisterForm((prev) => ({ ...prev, password: event.target.value }))}
                autoComplete="new-password"
              />
              <i className="bx bxs-lock-alt" />
            </div>
            <div className="forgot-link">
              <span>Create your account and enter Face It</span>
            </div>
            {registerError ? <p className="form-message error">{registerError}</p> : null}
            <button type="submit" className="btn" disabled={isLoading && active}>
              {isLoading && active ? "Creating..." : "Register"}
            </button>
            <p>or continue with</p>
            <div className="social-icons">
              <a href="#" onClick={(event) => event.preventDefault()} aria-label="Google">
                <i className="bx bxl-google" />
              </a>
              <a href="#" onClick={(event) => event.preventDefault()} aria-label="Facebook">
                <i className="bx bxl-facebook" />
              </a>
              <a href="#" onClick={(event) => event.preventDefault()} aria-label="Github">
                <i className="bx bxl-github" />
              </a>
              <a href="#" onClick={(event) => event.preventDefault()} aria-label="LinkedIn">
                <i className="bx bxl-linkedin" />
              </a>
            </div>
          </form>
        </div>

        <div className="toggle-box">
          <div className="toggle-panel toggle-left">
            <h1>Hello, Welcome!</h1>
            <p>Don't have an account yet?</p>
            <button
              type="button"
              className="btn register-btn"
              onClick={() => {
                setActive(true);
                setSearchParams({ mode: "register" });
              }}
            >
              Register
            </button>
          </div>

          <div className="toggle-panel toggle-right">
            <h1>Welcome Back!</h1>
            <p>Already have an account?</p>
            <button
              type="button"
              className="btn login-btn"
              onClick={() => {
                setActive(false);
                setSearchParams({ mode: "login" });
              }}
            >
              Login
            </button>
          </div>
        </div>
      </div>
    </div>
  );
}
