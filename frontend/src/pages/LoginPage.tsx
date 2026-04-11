import * as React from "react";
import { useNavigate } from "react-router-dom";

import "@/styles/login-template.css";
import { useAuthStore } from "@/stores/authStore";

export function LoginPage() {
  const navigate = useNavigate();
  const { login, register, isLoading } = useAuthStore();
  const [active, setActive] = React.useState(false);
  const [loginForm, setLoginForm] = React.useState({ username: "admin", password: "admin" });
  const [registerForm, setRegisterForm] = React.useState({ username: "", email: "", password: "" });
  const [loginError, setLoginError] = React.useState<string | null>(null);
  const [registerError, setRegisterError] = React.useState<string | null>(null);

  const handleLoginSubmit = async (event: React.FormEvent<HTMLFormElement>) => {
    event.preventDefault();
    setLoginError(null);
    if (!loginForm.username.trim() || !loginForm.password.trim()) {
      setLoginError("请输入用户名和密码。");
      return;
    }

    try {
      await login(loginForm.username.trim(), loginForm.password.trim());
      navigate("/chat");
    } catch (error) {
      setLoginError((error as Error).message || "登录失败，请稍后重试。");
    }
  };

  const handleRegisterSubmit = async (event: React.FormEvent<HTMLFormElement>) => {
    event.preventDefault();
    setRegisterError(null);
    if (!registerForm.username.trim() || !registerForm.password.trim()) {
      setRegisterError("请输入用户名和密码。");
      return;
    }

    try {
      await register(registerForm.username.trim(), registerForm.password.trim());
      navigate("/chat");
    } catch (error) {
      setRegisterError((error as Error).message || "注册失败，请稍后重试。");
    }
  };

  return (
    <div className="auth-template-page">
      <div className={`container${active ? " active" : ""}`}>
        <div className="form-box login">
          <form onSubmit={handleLoginSubmit}>
            <h1>登录</h1>
            <div className="input-box">
              <input
                type="text"
                placeholder="用户名"
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
                placeholder="密码"
                required
                value={loginForm.password}
                onChange={(event) => setLoginForm((prev) => ({ ...prev, password: event.target.value }))}
                autoComplete="current-password"
              />
              <i className="bx bxs-lock-alt" />
            </div>
            <div className="forgot-link">
              <span>演示账号：admin / admin</span>
            </div>
            {loginError ? <p className="form-message error">{loginError}</p> : null}
            <button type="submit" className="btn" disabled={isLoading && !active}>
              {isLoading && !active ? "登录中..." : "登录"}
            </button>
            <p>或通过以下方式了解系统能力</p>
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
            <h1>注册</h1>
            <div className="input-box">
              <input
                type="text"
                placeholder="用户名"
                required
                value={registerForm.username}
                onChange={(event) => setRegisterForm((prev) => ({ ...prev, username: event.target.value }))}
                autoComplete="username"
              />
              <i className="bx bxs-user" />
            </div>
            <div className="input-box">
              <input
                type="email"
                placeholder="邮箱"
                required
                value={registerForm.email}
                onChange={(event) => setRegisterForm((prev) => ({ ...prev, email: event.target.value }))}
                autoComplete="email"
              />
              <i className="bx bxs-envelope" />
            </div>
            <div className="input-box">
              <input
                type="password"
                placeholder="密码"
                required
                value={registerForm.password}
                onChange={(event) => setRegisterForm((prev) => ({ ...prev, password: event.target.value }))}
                autoComplete="new-password"
              />
              <i className="bx bxs-lock-alt" />
            </div>
            <div className="forgot-link">
              <span>当前接口仅提交用户名与密码</span>
            </div>
            {registerError ? <p className="form-message error">{registerError}</p> : null}
            <button type="submit" className="btn" disabled={isLoading && active}>
              {isLoading && active ? "注册中..." : "注册"}
            </button>
            <p>或使用社交平台入口样式</p>
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
            <h1>你好，欢迎进入 Face It</h1>
            <p>还没有账号？立即注册开始使用</p>
            <button type="button" className="btn register-btn" onClick={() => setActive(true)}>
              注册
            </button>
          </div>

          <div className="toggle-panel toggle-right">
            <h1>欢迎回来</h1>
            <p>已有账号？直接登录继续你的对话与面试训练</p>
            <button type="button" className="btn login-btn" onClick={() => setActive(false)}>
              登录
            </button>
          </div>
        </div>
      </div>
    </div>
  );
}
