"use client";

import { Button } from "@/components/ui/button";
import { useEffect } from "react";

export default function Error({
  error,
  reset,
}: {
  error: Error & { digest?: string };
  reset: () => void;
}) {
  useEffect(() => {
    // Log the error to an error reporting service
    console.error(error);
  }, [error]);

  return (
    <div className="flex min-h-screen flex-col items-center justify-center">
      <div className="flex flex-col items-center space-y-4 max-w-md text-center">
        <h2 className="text-2xl font-bold">Something went wrong!</h2>
        <p className="text-muted-foreground">
          We couldn&apos;t load the contract data. This might be because the data file is missing or there was a problem with the API.
        </p>
        <div className="flex gap-4">
          <Button onClick={() => reset()}>Try again</Button>
          <Button variant="outline" onClick={() => window.location.reload()}>
            Refresh page
          </Button>
        </div>
        <div className="text-sm text-muted-foreground mt-8 p-4 bg-muted rounded-md">
          <p className="font-semibold">Error details:</p>
          <p className="font-mono text-xs mt-2">{error.message}</p>
        </div>
      </div>
    </div>
  );
}
