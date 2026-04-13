import * as React from "react";
import { Virtuoso, type VirtuosoHandle } from "react-virtuoso";

import { MessageItem } from "@/components/chat/MessageItem";
import { cn } from "@/lib/utils";
import type { Message } from "@/types";

interface VirtualMessageListProps {
  messages: Message[];
  sessionKey?: string | null;
  isStreaming: boolean;
  initialTopMostItemIndex: { index: "LAST"; align: "end" };
  virtuosoRef: React.MutableRefObject<VirtuosoHandle | null>;
  onScrollerRef: (node: HTMLElement | null) => void;
  onTotalListHeightChanged: () => void;
}

export function VirtualMessageList({
  messages,
  sessionKey,
  isStreaming,
  initialTopMostItemIndex,
  virtuosoRef,
  onScrollerRef,
  onTotalListHeightChanged
}: VirtualMessageListProps) {
  const List = React.useMemo(() => {
    const Comp = React.forwardRef<HTMLDivElement, React.HTMLAttributes<HTMLDivElement>>(
      ({ className, ...props }, ref) => (
        <div
          ref={ref}
          className={cn("mx-auto max-w-[800px] space-y-10 px-6 pt-10 pb-2 md:px-8", className)}
          {...props}
        />
      )
    );
    Comp.displayName = "MessageList";
    return Comp;
  }, []);

  const Footer = React.useMemo(() => {
    const Comp = () => <div aria-hidden="true" className="h-8" />;
    Comp.displayName = "MessageListFooter";
    return Comp;
  }, []);

  return (
    <Virtuoso
      key={sessionKey ?? "empty"}
      ref={virtuosoRef}
      data={messages}
      initialTopMostItemIndex={initialTopMostItemIndex}
      followOutput={(atBottom) => {
        if (isStreaming) return false;
        return atBottom ? "auto" : false;
      }}
      scrollerRef={(node) => {
        onScrollerRef(node as HTMLElement | null);
      }}
      totalListHeightChanged={onTotalListHeightChanged}
      className="h-full"
      components={{ List, Footer }}
      itemContent={(index, message) => (
        <div className={index === messages.length - 1 ? "animate-fade-up" : ""}>
          <MessageItem message={message} isLast={index === messages.length - 1} />
        </div>
      )}
    />
  );
}
