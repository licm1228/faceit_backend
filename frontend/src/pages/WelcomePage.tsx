import { Link, useNavigate } from "react-router-dom";

import { FaceItMark } from "@/components/common/FaceItMark";
import { UserMenu } from "@/components/layout/UserMenu";
import { useAuthStore } from "@/stores/authStore";

const features = [
  "Chat Workspace",
  "Knowledge QA",
  "Mock Interview",
  "Admin Console",
  "Mixed Language UX",
  "Guest Preview"
];

const featureDescriptions = [
  "保留当前项目的聊天工作区心智，适合直接进入对话、总结、拆解和追问。",
  "结合知识库检索与回答生成，更贴近当前项目的问答和信息获取场景。",
  "围绕岗位、题目与追问节奏开展模拟面试，和现有 interview 能力保持一致。",
  "管理端继续独立存在，欢迎页只负责把普通用户自然引导到 chat 与登录流程。",
  "文案保留必要英文，同时整体语气更贴近 Face It 当前项目，而不是通用 SaaS 模板。",
  "未登录用户可以先看 welcome 与 chat 界面，再决定 Login / Register。"
];

const footerGroups = [
  {
    title: "Product",
    links: [
      { label: "Welcome Page", to: "/" },
      { label: "Chat", to: "/chat" },
      { label: "Login", to: "/login" }
    ]
  },
  {
    title: "Company",
    links: [
      { label: "Face It", to: "/" },
      { label: "Mock Interview", to: "/interview" },
      { label: "Admin", to: "/admin" }
    ]
  },
  {
    title: "Resources",
    links: [
      { label: "Get Started", to: "/chat" },
      { label: "Register", to: "/login?mode=register" },
      { label: "Sign In", to: "/login" }
    ]
  }
];

function WelcomeHeader() {
  const navigate = useNavigate();
  const isAuthenticated = useAuthStore((state) => state.isAuthenticated);

  return (
    <header className="fixed top-2 z-30 w-full md:top-6">
      <div className="mx-auto max-w-6xl px-4 sm:px-6">
        <div className="relative flex h-14 items-center justify-between gap-3 rounded-2xl bg-white/90 px-3 shadow-lg shadow-black/[0.03] backdrop-blur before:pointer-events-none before:absolute before:inset-0 before:rounded-[inherit] before:border before:border-transparent before:[background:linear-gradient(#F3F4F6,#E5E7EB)_border-box] before:[mask-composite:exclude_!important] before:[mask:linear-gradient(white_0_0)_padding-box,_linear-gradient(white_0_0)]">
          <div className="flex flex-1 items-center">
            <Link to="/" className="inline-flex items-center gap-3" aria-label="Face It Home">
              <span className="flex h-9 w-9 items-center justify-center rounded-xl bg-gradient-to-br from-blue-500 to-blue-300 text-white shadow-sm">
                <span className="flex h-full w-full items-center justify-center rounded-xl bg-white text-[#2563EB]">
                  <FaceItMark className="h-5 w-5" />
                </span>
              </span>
              <span className="text-sm font-semibold text-gray-900">Face It</span>
            </Link>
          </div>
          <div className="flex flex-1 items-center justify-end gap-3">
            {isAuthenticated ? (
              <UserMenu
                align="end"
                side="bottom"
                sideOffset={10}
                className="flex items-center gap-2 rounded-xl bg-white px-2.5 py-1.5 text-left transition hover:bg-gray-50 data-[state=open]:bg-gray-50"
              />
            ) : (
              <>
                <button
                  type="button"
                  className="btn-sm bg-white text-gray-800 shadow-sm hover:bg-gray-50"
                  onClick={() => navigate("/login")}
                >
                  Login
                </button>
                <button
                  type="button"
                  className="btn-sm bg-gray-800 text-gray-200 shadow-sm hover:bg-gray-900"
                  onClick={() => navigate("/login?mode=register")}
                >
                  Register
                </button>
              </>
            )}
          </div>
        </div>
      </div>
    </header>
  );
}

function PageIllustration() {
  return (
    <>
      <div className="pointer-events-none absolute left-1/2 top-0 -z-10 -translate-x-1/2" aria-hidden="true">
        <img className="max-w-none" src="/images/stripes.svg" width={768} alt="" />
      </div>
      <div className="pointer-events-none absolute -top-32 left-1/2 ml-[580px] -translate-x-1/2" aria-hidden="true">
        <div className="h-80 w-80 rounded-full bg-gradient-to-tr from-blue-500 opacity-50 blur-[160px]" />
      </div>
      <div className="pointer-events-none absolute left-1/2 top-[420px] ml-[380px] -translate-x-1/2" aria-hidden="true">
        <div className="h-80 w-80 rounded-full bg-gradient-to-tr from-blue-500 to-gray-900 opacity-50 blur-[160px]" />
      </div>
      <div className="pointer-events-none absolute left-1/2 top-[640px] -ml-[300px] -translate-x-1/2" aria-hidden="true">
        <div className="h-80 w-80 rounded-full bg-gradient-to-tr from-blue-500 to-gray-900 opacity-50 blur-[160px]" />
      </div>
    </>
  );
}

function HeroSection() {
  return (
    <section className="relative">
      <PageIllustration />
      <div className="mx-auto max-w-6xl px-4 sm:px-6">
        <div className="pb-12 pt-32 md:pb-20 md:pt-40">
          <div className="pb-12 text-center md:pb-16">
            <div className="mb-6 border-b [border-image:linear-gradient(to_right,transparent,#CBD5E1,transparent)1]">
              <div className="-mx-0.5 flex justify-center -space-x-3">
                {[1, 2, 3, 4, 5, 6].map((index) => (
                  <img
                    key={index}
                    className="box-content rounded-full border-2 border-gray-50"
                    src={
                      [
                        "/avatars/b_0a76fdf12c33b00551af060b4606f9d9.jpg",
                        "/avatars/b_688c3a98314f2cb8edfad342f2ef1ee7.jpg",
                        "/avatars/b_80198ee39325fe32f6bed1feeb88e047.jpg",
                        "/avatars/b_b5058679e485fc3ead6a63029ab4d838.jpg",
                        "/avatars/b_b902e83c6260a0089e0cd4aaef8430e4.jpg",
                        "/avatars/b_688c3a98314f2cb8edfad342f2ef1ee7.jpg"
                      ][index - 1]
                    }
                    width={32}
                    height={32}
                    alt={`Avatar ${index}`}
                  />
                ))}
              </div>
            </div>
            <h1 className="mb-6 text-5xl font-bold md:text-6xl">
              <span className="text-blue-600">Face It</span>, your AI partner
              <br className="max-lg:hidden" />
              for better interview practice
            </h1>
            <div className="mx-auto max-w-3xl">
              <p className="mb-8 text-lg text-gray-700">
                用更轻松的方式开始模拟面试、整理回答思路，并获得更清晰的反馈，助力你拿下大厂 Offer。
              </p>
              <div className="relative">
                <div className="mx-auto max-w-xs sm:flex sm:max-w-none sm:justify-center">
                  <Link
                    className="btn group mb-4 w-full bg-gradient-to-t from-blue-600 to-blue-500 bg-[length:100%_100%] bg-[bottom] text-white shadow-sm hover:bg-[length:100%_150%] sm:mb-0 sm:w-auto"
                    to="/chat"
                  >
                    <span className="relative inline-flex items-center">
                      Start Interview
                      <span className="ml-1 tracking-normal text-blue-300 transition-transform group-hover:translate-x-0.5">
                        -&gt;
                      </span>
                    </span>
                  </Link>
                  <a className="btn w-full bg-white text-gray-800 shadow-sm hover:bg-gray-50 sm:ml-4 sm:w-auto" href="#features">
                    Learn More
                  </a>
                </div>
              </div>
            </div>
          </div>
          <div className="mx-auto max-w-3xl">
            <div className="relative aspect-video rounded-2xl bg-gray-900 px-5 py-3 shadow-xl before:pointer-events-none before:absolute before:-inset-5 before:border-y before:[border-image:linear-gradient(to_right,transparent,#CBD5E1,transparent)1] after:absolute after:-inset-5 after:-z-10 after:border-x after:[border-image:linear-gradient(to_bottom,transparent,#CBD5E1,transparent)1]">
              <div className="relative mb-8 flex items-center justify-between before:block before:h-[9px] before:w-[41px] before:bg-[length:16px_9px] before:[background-image:radial-gradient(circle_at_4.5px_4.5px,#4B5563_4.5px,transparent_0)] after:w-[41px]">
                <span className="text-[13px] font-medium text-white">faceit.ai</span>
              </div>
              <div className="font-mono text-gray-500 [&_span]:opacity-0">
                <span className="animate-[code-1_10s_infinite] text-gray-200">open /</span>{" "}
                <span className="animate-[code-2_10s_infinite]">Welcome to Face It</span>
                <br />
                <span className="animate-[code-3_10s_infinite]">enter /chat</span>{" "}
                <span className="animate-[code-4_10s_infinite]">Guest preview enabled.</span>
                <br />
                <br />
                <span className="animate-[code-5_10s_infinite] text-gray-200">login --faceit</span>
                <br />
                <span className="animate-[code-6_10s_infinite]">Chat, history and interview unlocked.</span>
              </div>
            </div>
          </div>
        </div>
      </div>
    </section>
  );
}

function LogoOrbitSection() {
  return (
    <section id="features">
      <div className="mx-auto max-w-6xl px-4 sm:px-6">
        <div className="pb-12 md:pb-20">
          <div className="relative flex h-[324px] items-center justify-center">
            <div className="absolute -z-10">
              <svg className="fill-blue-500" xmlns="http://www.w3.org/2000/svg" width={164} height={41} viewBox="0 0 164 41" fill="none">
                <circle cx={1} cy={8} r={1} fillOpacity="0.24" />
                <circle cx={1} cy={1} r={1} fillOpacity="0.16" />
                <circle cx={1} cy={15} r={1} />
                <circle cx={1} cy={26} r={1} fillOpacity="0.64" />
                <circle cx={1} cy={33} r={1} fillOpacity="0.24" />
                <circle cx={8} cy={8} r={1} />
                <circle cx={8} cy={15} r={1} />
                <circle cx={8} cy={26} r={1} fillOpacity="0.24" />
                <circle cx={15} cy={15} r={1} fillOpacity="0.64" />
                <circle cx={15} cy={26} r={1} fillOpacity="0.16" />
                <circle cx={8} cy={33} r={1} />
                <circle cx={1} cy={40} r={1} />
              </svg>
            </div>
            <div className="absolute -z-10">
              <div className="h-20 w-[320px] rounded-full bg-blue-500/20 blur-3xl" />
            </div>
            <div className="absolute inset-x-0 top-0 -z-10 h-px bg-gradient-to-r from-transparent via-gray-200 to-transparent mix-blend-multiply" />
            <div className="absolute inset-x-0 bottom-0 -z-10 h-px bg-gradient-to-r from-transparent via-gray-200 to-transparent mix-blend-multiply" />
            <div className="absolute inset-x-[200px] top-1/2 -z-10 h-px bg-gradient-to-r from-transparent via-blue-500/60 to-transparent mix-blend-multiply" />
            <div className="absolute inset-x-0 top-1/2 -z-10 h-px -translate-y-[82px] bg-gradient-to-r from-transparent via-gray-200 to-transparent mix-blend-multiply before:absolute before:inset-y-0 before:w-24 before:animate-[line_10s_ease-in-out_infinite_both] before:bg-gradient-to-r before:via-blue-500" />
            <div className="absolute inset-x-0 top-1/2 -z-10 h-px translate-y-[82px] bg-gradient-to-r from-transparent via-gray-200 to-transparent mix-blend-multiply before:absolute before:inset-y-0 before:w-24 before:animate-[line_10s_ease-in-out_infinite_5s_both] before:bg-gradient-to-r before:via-blue-500" />
            <div className="absolute inset-y-0 left-1/2 -z-10 w-px -translate-x-[216px] bg-gradient-to-b from-gray-200 to-transparent mix-blend-multiply" />
            <div className="absolute inset-y-0 left-1/2 -z-10 w-px translate-x-[216px] bg-gradient-to-t from-gray-200 to-transparent mix-blend-multiply" />

            <div className="absolute before:absolute before:-inset-3 before:animate-spin before:rounded-full before:border before:border-transparent before:[mask-composite:exclude_!important] before:[mask:linear-gradient(white_0_0)_padding-box,_linear-gradient(white_0_0)] before:[background:conic-gradient(from_180deg,transparent,#3B82F6)_border-box] [animation-duration:3s]">
              <div className="animate-[breath_8s_ease-in-out_infinite_both]">
                <div className="flex h-24 w-24 items-center justify-center rounded-full bg-white shadow-lg shadow-black/[0.03] before:absolute before:inset-0 before:m-[8.334%] before:rounded-[inherit] before:border before:border-gray-700/5 before:bg-gray-200/60 before:[mask-image:linear-gradient(to_bottom,black,transparent)]">
                  <FaceItMark className="relative h-8 w-8 text-blue-500" />
                </div>
              </div>
            </div>

            {[
              { cls: "-translate-x-[136px]", size: "h-16 w-16", img: "/images/logo-02.svg", inner: "7s_ease-in-out_3s", w: 23, h: 22 },
              { cls: "translate-x-[136px]", size: "h-16 w-16", img: "/images/logo-03.svg", inner: "7s_ease-in-out_3.5s", w: 22, h: 22 },
              { cls: "-translate-x-[216px] -translate-y-[82px]", size: "h-20 w-20", img: "/images/logo-04.svg", inner: "6s_ease-in-out_3.5s", w: 24, h: 22 },
              { cls: "-translate-y-[82px] translate-x-[216px]", size: "h-20 w-20", img: "/images/logo-05.svg", inner: "6s_ease-in-out_1.5s", w: 25, h: 25 },
              { cls: "translate-x-[216px] translate-y-[82px]", size: "h-20 w-20", img: "/images/logo-06.svg", inner: "6s_ease-in-out_2s", w: 20, h: 18 },
              { cls: "-translate-x-[216px] translate-y-[82px]", size: "h-20 w-20", img: "/images/logo-07.svg", inner: "6s_ease-in-out_2.5s", w: 25, h: 25 }
            ].map((item) => (
              <div key={item.img} className={`absolute ${item.cls}`}>
                <div className={`animate-[breath_${item.inner}_infinite_both]`}>
                  <div className={`flex ${item.size} items-center justify-center rounded-full bg-white shadow-lg shadow-black/[0.03] before:absolute before:inset-0 before:m-[8.334%] before:rounded-[inherit] before:border before:border-gray-700/5 before:bg-gray-200/60 before:[mask-image:linear-gradient(to_bottom,black,transparent)]`}>
                    <img className="relative" src={item.img} width={item.w} height={item.h} alt="" />
                  </div>
                </div>
              </div>
            ))}
          </div>
        </div>
      </div>
    </section>
  );
}

function PlanetSection() {
  return (
    <section className="relative before:absolute before:inset-0 before:-z-20 before:bg-gray-900">
      <div className="mx-auto max-w-6xl px-4 sm:px-6">
        <div className="py-12 md:py-20">
          <div className="mx-auto max-w-3xl pb-16 text-center md:pb-20">
            <h2 className="text-3xl font-bold text-gray-200 md:text-4xl">
              From first question to final answer, Face It keeps the whole flow in one place
            </h2>
          </div>
          <div className="pb-16 md:pb-20 text-center">
            <div className="relative inline-flex rounded-full before:absolute before:inset-0 before:-z-10 before:scale-[.85] before:animate-pulse before:bg-gradient-to-b before:from-blue-900 before:to-sky-700/50 before:blur-3xl after:absolute after:inset-0 after:rounded-[inherit] after:[background:radial-gradient(closest-side,#3B82F6,transparent)]">
              <img className="rounded-full bg-gray-900" src="/images/planet.png" width={400} height={400} alt="Planet" />
              <div className="pointer-events-none" aria-hidden="true">
                <img className="absolute -right-64 -top-20 z-10 max-w-none" src="/images/planet-overlay.svg" width={789} height={755} alt="" />
                <img className="absolute -left-28 top-16 z-10 animate-[float_4s_ease-in-out_infinite_both] opacity-80 transition-opacity duration-500" src="/images/planet-tag-01.png" width={253} height={56} alt="" />
                <img className="absolute left-56 top-7 z-10 animate-[float_4s_ease-in-out_infinite_1s_both] opacity-30 transition-opacity duration-500" src="/images/planet-tag-02.png" width={241} height={56} alt="" />
                <img className="absolute -left-20 bottom-24 z-10 animate-[float_4s_ease-in-out_infinite_2s_both] opacity-25 transition-opacity duration-500" src="/images/planet-tag-03.png" width={243} height={56} alt="" />
                <img className="absolute bottom-32 left-64 z-10 animate-[float_4s_ease-in-out_infinite_3s_both] opacity-80 transition-opacity duration-500" src="/images/planet-tag-04.png" width={251} height={56} alt="" />
              </div>
            </div>
          </div>
          <div className="grid overflow-hidden sm:grid-cols-2 lg:grid-cols-3 *:relative *:p-6 *:before:absolute *:before:bg-gray-800 *:before:[block-size:100vh] *:before:[inline-size:1px] *:before:[inset-block-start:0] *:before:[inset-inline-start:-1px] *:after:absolute *:after:bg-gray-800 *:after:[block-size:1px] *:after:[inline-size:100vw] *:after:[inset-block-start:-1px] *:after:[inset-inline-start:0] md:*:p-10">
            {features.map((title, index) => (
              <article key={title}>
                <h3 className="mb-2 flex items-center space-x-2 font-medium text-gray-200">
                  <svg className="fill-blue-500" xmlns="http://www.w3.org/2000/svg" width={16} height={16}>
                    <circle cx={8} cy={8} r={7} />
                  </svg>
                  <span>{title}</span>
                </h3>
                <p className="text-[15px] text-gray-400">{featureDescriptions[index]}</p>
              </article>
            ))}
          </div>
        </div>
      </div>
    </section>
  );
}

function TestimonialSection() {
  return (
    <section>
      <div className="mx-auto max-w-2xl px-4 sm:px-6">
        <div className="py-12 md:py-20">
          <div className="space-y-3 text-center">
            <div className="relative inline-flex">
              <svg className="absolute -left-6 -top-2 -z-10" width={40} height={49} viewBox="0 0 40 49" fill="none" xmlns="http://www.w3.org/2000/svg">
                <path d="M22.7976 -0.000136375L39.9352 23.4746L33.4178 31.7234L13.7686 11.4275L22.7976 -0.000136375ZM9.34947 17.0206L26.4871 40.4953L19.9697 48.7441L0.320491 28.4482L9.34947 17.0206Z" fill="#D1D5DB" />
              </svg>
              <img className="rounded-full" src="/images/large-testimonial.jpg" width={48} height={48} alt="Large testimonial" />
            </div>
            <p className="text-2xl font-bold text-gray-900">
              “Face It 把知识问答、日常聊天和模拟面试放进同一个入口里。From welcome page to chat,
              the product feels <em className="italic text-gray-500">focused, practical and ready to use</em>.”
            </p>
            <div className="text-sm font-medium text-gray-500">
              <span className="text-gray-700">Current Project</span> <span className="text-gray-400">/</span>{" "}
              <span className="text-blue-500">Face It welcome experience</span>
            </div>
          </div>
        </div>
      </div>
    </section>
  );
}

function CtaSection() {
  return (
    <section>
      <div className="mx-auto max-w-6xl px-4 sm:px-6">
        <div className="relative overflow-hidden rounded-2xl text-center shadow-xl before:pointer-events-none before:absolute before:inset-0 before:-z-10 before:rounded-2xl before:bg-gray-900">
          <div className="absolute bottom-0 left-1/2 -z-10 -translate-x-1/2 translate-y-1/2" aria-hidden="true">
            <div className="h-56 w-[480px] rounded-full border-[20px] border-blue-500 blur-3xl" />
          </div>
          <div className="pointer-events-none absolute left-1/2 top-0 -z-10 -translate-x-1/2" aria-hidden="true">
            <img className="max-w-none" src="/images/stripes-dark.svg" width={768} height={432} alt="" />
          </div>
          <div className="px-4 py-12 md:px-12 md:py-20">
            <h2 className="mb-6 border-y text-3xl font-bold text-gray-200 [border-image:linear-gradient(to_right,transparent,#334155,transparent)1] md:mb-12 md:text-4xl">
              Enter Face It and continue in chat
            </h2>
            <div className="mx-auto max-w-xs sm:flex sm:max-w-none sm:justify-center">
              <Link
                className="btn group mb-4 w-full bg-gradient-to-t from-blue-600 to-blue-500 bg-[length:100%_100%] bg-[bottom] text-white shadow-sm hover:bg-[length:100%_150%] sm:mb-0 sm:w-auto"
                to="/chat"
              >
                <span className="relative inline-flex items-center">
                  Start Chat
                  <span className="ml-1 tracking-normal text-blue-300 transition-transform group-hover:translate-x-0.5">
                    -&gt;
                  </span>
                </span>
              </Link>
            </div>
          </div>
        </div>
      </div>
    </section>
  );
}

function WelcomeFooter() {
  return (
    <footer>
      <div className="mx-auto max-w-6xl px-4 sm:px-6">
        <div className="grid gap-10 border-t py-8 [border-image:linear-gradient(to_right,transparent,#E2E8F0,transparent)1] sm:grid-cols-12 md:py-12">
          <div className="space-y-2 sm:col-span-12 lg:col-span-4">
            <div>
            <Link to="/" className="inline-flex items-center gap-3" aria-label="Face It">
                <span className="flex h-9 w-9 items-center justify-center rounded-xl bg-gradient-to-br from-blue-500 to-blue-300 text-white shadow-sm">
                  <span className="flex h-full w-full items-center justify-center rounded-xl bg-white text-[#2563EB]">
                    <FaceItMark className="h-5 w-5" />
                  </span>
                </span>
                <span className="text-sm font-semibold text-gray-900">Face It</span>
              </Link>
            </div>
            <div className="text-sm text-gray-600">&copy; Face It - Chat, Knowledge QA and Interview.</div>
          </div>

          {footerGroups.map((group) => (
            <div key={group.title} className="space-y-2 sm:col-span-6 md:col-span-3 lg:col-span-2">
              <h3 className="text-sm font-medium">{group.title}</h3>
              <ul className="space-y-2 text-sm">
                {group.links.map((link) => (
                  <li key={link.label}>
                    <Link className="text-gray-600 transition hover:text-gray-900" to={link.to}>
                      {link.label}
                    </Link>
                  </li>
                ))}
              </ul>
            </div>
          ))}

          <div className="space-y-2 sm:col-span-6 md:col-span-3 lg:col-span-2">
            <h3 className="text-sm font-medium">Social</h3>
            <ul className="flex gap-1">
              {["Twitter", "Medium", "Github"].map((label) => (
                <li key={label}>
                  <a
                    className="flex h-8 w-8 items-center justify-center text-blue-500 transition hover:text-blue-600"
                    href="#0"
                    aria-label={label}
                    onClick={(event) => event.preventDefault()}
                  >
                    <FaceItMark className="h-4 w-4" />
                  </a>
                </li>
              ))}
            </ul>
          </div>
        </div>
      </div>

      <div className="relative -mt-16 h-60 w-full overflow-hidden" aria-hidden="true">
        <div className="pointer-events-none absolute left-1/2 -z-10 -translate-x-1/2 text-center text-[200px] font-bold leading-none text-gray-200/70 md:text-[348px]">
          Face It
        </div>
        <div className="absolute bottom-0 left-1/2 -translate-x-1/2 translate-y-2/3" aria-hidden="true">
          <div className="h-56 w-56 rounded-full border-[20px] border-blue-700 blur-[80px]" />
        </div>
      </div>
    </footer>
  );
}

export function WelcomePage() {
  return (
    <div className="h-screen overflow-y-auto bg-white text-gray-900">
      <WelcomeHeader />
      <main className="grow">
        <HeroSection />
        <LogoOrbitSection />
        <PlanetSection />
        <TestimonialSection />
        <CtaSection />
      </main>
      <WelcomeFooter />
    </div>
  );
}
