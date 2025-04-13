export default function Loading() {
  return (
    <div className="flex min-h-screen flex-col items-center justify-center">
      <div className="flex flex-col items-center space-y-4">
        <div className="h-16 w-16 animate-spin rounded-full border-t-4 border-b-4 border-primary"></div>
        <h2 className="text-xl font-semibold">Loading contract data...</h2>
        <p className="text-sm text-muted-foreground">Fetching real blockchain data from Ethereum mainnet</p>
      </div>
    </div>
  );
}
