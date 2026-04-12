import { lazy, Suspense } from "react";
import { Navigate, createBrowserRouter, useLocation } from "react-router-dom";

import Loader from "@/components/layout/Loader";
import { useAuthStore } from "@/stores/authStore";

const LoginPage = lazy(() => import("@/pages/LoginPage").then((mod) => ({ default: mod.LoginPage })));
const WelcomePage = lazy(() => import("@/pages/WelcomePage").then((mod) => ({ default: mod.WelcomePage })));
const ChatPage = lazy(() => import("@/pages/ChatPage").then((mod) => ({ default: mod.ChatPage })));
const InterviewReportPage = lazy(() =>
  import("@/pages/InterviewReportPage").then((mod) => ({ default: mod.InterviewReportPage }))
);
const NotFoundPage = lazy(() => import("@/pages/NotFoundPage").then((mod) => ({ default: mod.NotFoundPage })));
const AdminLayout = lazy(() => import("@/pages/admin/AdminLayout").then((mod) => ({ default: mod.AdminLayout })));
const DashboardPage = lazy(() =>
  import("@/pages/admin/dashboard/DashboardPage").then((mod) => ({ default: mod.DashboardPage }))
);
const KnowledgeListPage = lazy(() =>
  import("@/pages/admin/knowledge/KnowledgeListPage").then((mod) => ({ default: mod.KnowledgeListPage }))
);
const KnowledgeDocumentsPage = lazy(() =>
  import("@/pages/admin/knowledge/KnowledgeDocumentsPage").then((mod) => ({ default: mod.KnowledgeDocumentsPage }))
);
const KnowledgeChunksPage = lazy(() =>
  import("@/pages/admin/knowledge/KnowledgeChunksPage").then((mod) => ({ default: mod.KnowledgeChunksPage }))
);
const IntentTreePage = lazy(() =>
  import("@/pages/admin/intent-tree/IntentTreePage").then((mod) => ({ default: mod.IntentTreePage }))
);
const IntentListPage = lazy(() =>
  import("@/pages/admin/intent-tree/IntentListPage").then((mod) => ({ default: mod.IntentListPage }))
);
const IntentEditPage = lazy(() =>
  import("@/pages/admin/intent-tree/IntentEditPage").then((mod) => ({ default: mod.IntentEditPage }))
);
const IngestionPage = lazy(() =>
  import("@/pages/admin/ingestion/IngestionPage").then((mod) => ({ default: mod.IngestionPage }))
);
const RagTracePage = lazy(() =>
  import("@/pages/admin/traces/RagTracePage").then((mod) => ({ default: mod.RagTracePage }))
);
const RagTraceDetailPage = lazy(() =>
  import("@/pages/admin/traces/RagTraceDetailPage").then((mod) => ({ default: mod.RagTraceDetailPage }))
);
const SystemSettingsPage = lazy(() =>
  import("@/pages/admin/settings/SystemSettingsPage").then((mod) => ({ default: mod.SystemSettingsPage }))
);
const SampleQuestionPage = lazy(() =>
  import("@/pages/admin/sample-questions/SampleQuestionPage").then((mod) => ({ default: mod.SampleQuestionPage }))
);
const QueryTermMappingPage = lazy(() =>
  import("@/pages/admin/query-term-mapping/QueryTermMappingPage").then((mod) => ({ default: mod.QueryTermMappingPage }))
);
const UserListPage = lazy(() =>
  import("@/pages/admin/users/UserListPage").then((mod) => ({ default: mod.UserListPage }))
);
const PositionManagementPage = lazy(() =>
  import("@/pages/admin/interview/PositionManagementPage").then((mod) => ({ default: mod.PositionManagementPage }))
);
const QuestionManagementPage = lazy(() =>
  import("@/pages/admin/interview/QuestionManagementPage").then((mod) => ({ default: mod.QuestionManagementPage }))
);
const InterviewSessionsPage = lazy(() =>
  import("@/pages/admin/interview/InterviewSessionsPage").then((mod) => ({ default: mod.InterviewSessionsPage }))
);

function withSuspense(children: JSX.Element) {
  return (
    <Suspense
      fallback={
        <div className="flex min-h-screen items-center justify-center bg-[#FAFAFA] px-6">
          <Loader label="页面加载中..." />
        </div>
      }
    >
      {children}
    </Suspense>
  );
}

function RequireAuth({ children }: { children: JSX.Element }) {
  const location = useLocation();
  const isAuthenticated = useAuthStore((state) => state.isAuthenticated);
  if (!isAuthenticated) {
    return (
      <Navigate
        to="/login"
        replace
        state={{
          redirectTo: location.pathname,
          redirectState: location.state
        }}
      />
    );
  }
  return children;
}

function RequireAdmin({ children }: { children: JSX.Element }) {
  const user = useAuthStore((state) => state.user);
  const isAuthenticated = useAuthStore((state) => state.isAuthenticated);

  if (!isAuthenticated) {
    return <Navigate to="/login" replace />;
  }

  if (user?.role !== "admin") {
    return <Navigate to="/chat" replace />;
  }

  return children;
}

function RedirectIfAuth({ children }: { children: JSX.Element }) {
  const isAuthenticated = useAuthStore((state) => state.isAuthenticated);
  if (isAuthenticated) {
    return <Navigate to="/chat" replace />;
  }
  return children;
}

export const router = createBrowserRouter([
  {
    path: "/",
    element: withSuspense(<WelcomePage />)
  },
  {
    path: "/login",
    element: (
      <RedirectIfAuth>
        {withSuspense(<LoginPage />)}
      </RedirectIfAuth>
    )
  },
  {
    path: "/chat",
    element: withSuspense(<ChatPage />)
  },
  {
    path: "/chat/:sessionId",
    element: withSuspense(<ChatPage />)
  },
  {
    path: "/interview",
    element: <Navigate to="/chat" replace />
  },
  {
    path: "/interview-report/:sessionId",
    element: (
      <RequireAuth>
        {withSuspense(<InterviewReportPage />)}
      </RequireAuth>
    )
  },
  {
    path: "/admin",
    element: (
      <RequireAdmin>
        {withSuspense(<AdminLayout />)}
      </RequireAdmin>
    ),
    children: [
      {
        index: true,
        element: <Navigate to="/admin/dashboard" replace />
      },
      {
        path: "dashboard",
        element: withSuspense(<DashboardPage />)
      },
      {
        path: "knowledge",
        element: withSuspense(<KnowledgeListPage />)
      },
      {
        path: "knowledge/:kbId",
        element: withSuspense(<KnowledgeDocumentsPage />)
      },
      {
        path: "knowledge/:kbId/docs/:docId",
        element: withSuspense(<KnowledgeChunksPage />)
      },
      {
        path: "intent-tree",
        element: withSuspense(<IntentTreePage />)
      },
      {
        path: "intent-list",
        element: withSuspense(<IntentListPage />)
      },
      {
        path: "intent-list/:id/edit",
        element: withSuspense(<IntentEditPage />)
      },
      {
        path: "ingestion",
        element: withSuspense(<IngestionPage />)
      },
      {
        path: "traces",
        element: withSuspense(<RagTracePage />)
      },
      {
        path: "traces/:traceId",
        element: withSuspense(<RagTraceDetailPage />)
      },
      {
        path: "settings",
        element: withSuspense(<SystemSettingsPage />)
      },
      {
        path: "sample-questions",
        element: withSuspense(<SampleQuestionPage />)
      },
      {
        path: "mappings",
        element: withSuspense(<QueryTermMappingPage />)
      },
      {
        path: "users",
        element: withSuspense(<UserListPage />)
      },
      {
        path: "interview/positions",
        element: withSuspense(<PositionManagementPage />)
      },
      {
        path: "interview/questions",
        element: withSuspense(<QuestionManagementPage />)
      },
      {
        path: "interview/sessions",
        element: withSuspense(<InterviewSessionsPage />)
      }
    ]
  },
  {
    path: "*",
    element: withSuspense(<NotFoundPage />)
  }
]);
