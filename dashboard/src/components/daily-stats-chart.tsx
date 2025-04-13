"use client";

import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { DailyStats } from "@/lib/data";
import { useEffect, useRef } from "react";

// Import Chart.js dynamically on the client side
// Using a more specific type for Chart
let Chart: typeof import("chart.js/auto").default | null = null;

if (typeof window !== "undefined") {
  import("chart.js/auto").then((module) => {
    Chart = module.default;
  });
}

interface DailyStatsChartProps {
  dailyStats: DailyStats[];
  title: string;
}

// Define a type for the Chart instance to avoid using 'any'
type ChartInstance = {
  destroy: () => void;
};

export function DailyStatsChart({ dailyStats, title }: DailyStatsChartProps) {
  const chartRef = useRef<HTMLCanvasElement>(null);
  // Use a more specific type for the chart instance
  const chartInstance = useRef<ChartInstance | null>(null);

  // Format timestamp to readable date
  const formatDate = (timestamp: number) => {
    return new Date(timestamp * 1000).toLocaleDateString();
  };

  useEffect(() => {
    if (!chartRef.current || !dailyStats || dailyStats.length === 0 || !Chart) {
      return;
    }

    // Destroy previous chart if it exists
    if (chartInstance.current) {
      chartInstance.current.destroy();
    }

    const ctx = chartRef.current.getContext("2d");
    if (!ctx) return;

    // Sort data by timestamp
    const sortedData = [...dailyStats].sort((a, b) => a.day_timestamp - b.day_timestamp);

    // Prepare data for the chart
    const labels = sortedData.map((stat) => formatDate(stat.day_timestamp));
    const activeContractsData = sortedData.map((stat) => stat.active_contracts);
    const newContractsData = sortedData.map((stat) => stat.new_contracts);
    const totalCallsData = sortedData.map((stat) => stat.total_calls);

    // Create the chart
    chartInstance.current = new Chart(ctx, {
      type: "line",
      data: {
        labels,
        datasets: [
          {
            label: "Active Smart Contracts",
            data: activeContractsData,
            borderColor: "rgb(59, 130, 246)",
            backgroundColor: "rgba(59, 130, 246, 0.1)",
            tension: 0.3,
            fill: true,
          },
          {
            label: "New Smart Contracts",
            data: newContractsData,
            borderColor: "rgb(16, 185, 129)",
            backgroundColor: "rgba(16, 185, 129, 0.1)",
            tension: 0.3,
            fill: true,
          },
          {
            label: "Total Calls (scaled)",
            data: totalCallsData.map((calls) => calls / 100), // Scale down for better visualization
            borderColor: "rgb(249, 115, 22)",
            backgroundColor: "rgba(249, 115, 22, 0.1)",
            tension: 0.3,
            fill: true,
            yAxisID: "y1",
          },
        ],
      },
      options: {
        responsive: true,
        maintainAspectRatio: false,
        scales: {
          x: {
            title: {
              display: true,
              text: "Date",
            },
          },
          y: {
            beginAtZero: true,
            title: {
              display: true,
              text: "Number of Smart Contracts",
            },
          },
          y1: {
            beginAtZero: true,
            position: "right",
            title: {
              display: true,
              text: "Total Calls (÷100)",
            },
            grid: {
              drawOnChartArea: false,
            },
          },
        },
        plugins: {
          tooltip: {
            callbacks: {
              label: function (context: { dataset: { label?: string }; parsed: { y: number } }) {
                let label = context.dataset.label || "";
                if (label) {
                  label += ": ";
                }
                if (context.dataset.label === "Total Calls (scaled)") {
                  label += (context.parsed.y * 100).toLocaleString();
                } else {
                  label += context.parsed.y.toLocaleString();
                }
                return label;
              },
            },
          },
        },
      },
    });

    return () => {
      if (chartInstance.current) {
        chartInstance.current.destroy();
      }
    };
  }, [dailyStats]);

  return (
    <Card className="col-span-2">
      <CardHeader>
        <CardTitle>{title}</CardTitle>
      </CardHeader>
      <CardContent className="h-80">
        {dailyStats && dailyStats.length > 0 ? (
          <canvas ref={chartRef} />
        ) : (
          <div className="flex h-full items-center justify-center">
            <p className="text-muted-foreground">No daily stats available</p>
          </div>
        )}
      </CardContent>
    </Card>
  );
}
