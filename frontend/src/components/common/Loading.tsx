import Loader from "@/components/layout/Loader";

interface LoadingProps {
  label?: string;
  className?: string;
}

export function Loading({ label = "加载中...", className }: LoadingProps) {
  return <Loader label={label} className={className} />;
}
