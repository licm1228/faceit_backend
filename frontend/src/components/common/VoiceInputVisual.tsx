import { cn } from "@/lib/utils";

type VoiceEqualizerIconProps = {
  className?: string;
  barClassName?: string;
};

export function VoiceEqualizerIcon({ className, barClassName }: VoiceEqualizerIconProps) {
  return (
    <span
      aria-hidden="true"
      className={cn("inline-flex h-4 w-4 shrink-0 items-center justify-center overflow-hidden", className)}
    >
      <span className="voice-eq">
        {[0, 1, 2].map((index) => (
          <span
            key={index}
            className={cn("voice-eq__bar", barClassName)}
            style={{ animationDelay: `${index * 140}ms` }}
          />
        ))}
      </span>
    </span>
  );
}
