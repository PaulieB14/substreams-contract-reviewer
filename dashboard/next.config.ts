import type { NextConfig } from "next";

const nextConfig: NextConfig = {
  output: 'standalone',
  reactStrictMode: true,
  swcMinify: true,
  images: {
    domains: ['substreams-contract-reviewer.vercel.app'],
    unoptimized: true,
  },
  // Ensure static files are properly served
  async rewrites() {
    return [
      {
        source: '/results/:path*',
        destination: '/results/:path*',
      },
    ];
  },
};

export default nextConfig;
