import { cn } from "@/lib/utils";

interface LoaderProps {
  label?: string;
  className?: string;
}

export default function Loader({ label, className }: LoaderProps) {
  return (
    <div className={cn("flex flex-col items-center justify-center gap-3", className)}>
      <style>{`
        .loader-bounce-step {
          position: relative;
          width: 120px;
          height: 90px;
        }

        .loader-bounce-step__ball {
          position: absolute;
          bottom: 30px;
          left: 50px;
          height: 30px;
          width: 30px;
          border-radius: 9999px;
          background: #2a9d8f;
          animation: loader-bounce-step-ball 0.5s ease-in-out infinite alternate;
        }

        .loader-bounce-step__steps {
          position: absolute;
          right: 0;
          top: 0;
          height: 7px;
          width: 45px;
          border-radius: 4px;
          box-shadow:
            0 5px 0 #f2f2f2,
            -35px 50px 0 #f2f2f2,
            -70px 95px 0 #f2f2f2;
          animation: loader-bounce-step-steps 1s ease-in-out infinite;
        }

        @keyframes loader-bounce-step-ball {
          0% {
            transform: scale(1, 0.7);
          }

          40% {
            transform: scale(0.8, 1.2);
          }

          60% {
            transform: scale(1, 1);
          }

          100% {
            bottom: 140px;
          }
        }

        @keyframes loader-bounce-step-steps {
          0% {
            box-shadow:
              0 10px 0 rgba(0, 0, 0, 0),
              0 10px 0 #f2f2f2,
              -35px 50px 0 #f2f2f2,
              -70px 90px 0 #f2f2f2;
          }

          100% {
            box-shadow:
              0 10px 0 #f2f2f2,
              -35px 50px 0 #f2f2f2,
              -70px 90px 0 #f2f2f2,
              -70px 90px 0 rgba(0, 0, 0, 0);
          }
        }
      `}</style>
      <div className="loader-bounce-step" aria-hidden="true">
        <div className="loader-bounce-step__ball" />
        <div className="loader-bounce-step__steps" />
      </div>
      {label ? <span className="text-sm text-muted-foreground">{label}</span> : null}
    </div>
  );
}
