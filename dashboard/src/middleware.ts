import { NextResponse } from 'next/server';
import type { NextRequest } from 'next/server';

export function middleware(request: NextRequest) {
  // Log the request path for debugging
  console.log(`Middleware processing request for: ${request.nextUrl.pathname}`);

  // Special handling for results directory
  if (request.nextUrl.pathname.startsWith('/results/')) {
    console.log('Handling results request');
    // Pass through to the results directory
    return NextResponse.next();
  }

  // Default handling for other routes
  return NextResponse.next();
}

// Configure which paths should trigger this middleware
export const config = {
  matcher: [
    /*
     * Match all request paths except:
     * - _next/static (static files)
     * - _next/image (image optimization files)
     * - favicon.ico (favicon file)
     */
    '/((?!_next/static|_next/image|favicon.ico).*)',
  ],
};
