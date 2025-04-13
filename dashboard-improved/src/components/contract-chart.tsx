"use client";

import { useEffect, useRef } from "react";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Contract } from "@/lib/data";
import Chart from "chart.js/auto";

interface ContractChartProps {
  contracts: Contract[];
  title: string;
  type: "calls" | "wallets" | "avg";
  colorScheme?: string[];
}

export function ContractChart({ contracts, title, type, colorScheme }: ContractChartProps) {
  const chartRef = useRef<HTMLCanvasElement>(null);
  const chartInstance = useRef<Chart | null>(null);

  // Default color scheme
  const defaultColors = [
    'rgba(59, 130, 246, 0.7)', // Blue
    'rgba(16, 185, 129, 0.7)', // Green
    'rgba(249, 115, 22, 0.7)', // Orange
    'rgba(239, 68, 68, 0.7)',  // Red
    'rgba(139, 92, 246, 0.7)', // Purple
    'rgba(236, 72, 153, 0.7)', // Pink
    'rgba(234, 179, 8, 0.7)',  // Yellow
    'rgba(20, 184, 166, 0.7)', // Teal
    'rgba(99, 102, 241, 0.7)', // Indigo
    'rgba(244, 63, 94, 0.7)',  // Rose
  ];

  const colors = colorScheme || defaultColors;

  useEffect(() => {
    if (!chartRef.current) return;

    // Destroy previous chart if it exists
    if (chartInstance.current) {
      chartInstance.current.destroy();
    }

    // Sort contracts based on the type
    const sortedContracts = [...contracts].sort((a, b) => {
      if (type === "calls") return b.total_calls - a.total_calls;
      if (type === "wallets") return b.unique_wallets - a.unique_wallets;
      return b.avg_calls_per_wallet - a.avg_calls_per_wallet;
    }).slice(0, 10); // Only show top 10

    // Prepare data based on type
    const labels = sortedContracts.map(c => c.address.substring(0, 8) + '...');
    const data = sortedContracts.map(c => {
      if (type === "calls") return c.total_calls;
      if (type === "wallets") return c.unique_wallets;
      return c.avg_calls_per_wallet;
    });

    // Create chart
    const ctx = chartRef.current.getContext('2d');
    if (!ctx) return;

    chartInstance.current = new Chart(ctx, {
      type: 'bar',
      data: {
        labels,
        datasets: [{
          label: type === "calls" ? 'Total Calls' : 
                 type === "wallets" ? 'Unique Wallets' : 
                 'Avg Calls per Wallet',
          data,
          backgroundColor: colors,
          borderColor: colors.map(color => color.replace('0.7', '1')),
          borderWidth: 1
        }]
      },
      options: {
        responsive: true,
        maintainAspectRatio: false,
        plugins: {
          legend: {
            display: false,
          },
          tooltip: {
            callbacks: {
              title: function(tooltipItems: Array<{dataIndex: number}>) {
                const idx = tooltipItems[0].dataIndex;
                return sortedContracts[idx].address;
              }
            }
          }
        },
        scales: {
          y: {
            beginAtZero: true
          }
        }
      }
    });

    return () => {
      if (chartInstance.current) {
        chartInstance.current.destroy();
      }
    };
  }, [contracts, type, colors]);

  return (
    <Card className="col-span-1">
      <CardHeader>
        <CardTitle>{title}</CardTitle>
      </CardHeader>
      <CardContent className="h-80">
        <canvas ref={chartRef} />
      </CardContent>
    </Card>
  );
}
