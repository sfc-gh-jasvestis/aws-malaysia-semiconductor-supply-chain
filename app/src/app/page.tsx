'use client';

import { useEffect, useState } from 'react';
import { AppLayout } from '@/components/AppLayout';
import { KPICard } from '@/components/KPICard';
import { Chart } from '@/components/Chart';
import { DataTable } from '@/components/DataTable';
import { AskAI } from '@/components/AskAI';
import { ActionMemo } from '@/components/ActionMemo';
import { GeoMap } from '@/components/GeoMap';
import { ArchitectureDiagram } from '@/components/ArchitectureDiagram';

interface DemoNarrative {
  title: string;
  duration: string;
  thesis: string;
  tabs: any[];
}

export default function HomePage() {
  const [narrative, setNarrative] = useState<DemoNarrative | null>(null);
  const [data, setData] = useState<any>(null);

  useEffect(() => {
    fetch('/demo_narrative.json')
      .then((r) => r.json())
      .then(setNarrative)
      .catch(() => {});
    fetch('/api/data')
      .then((r) => r.json())
      .then(setData)
      .catch(() => {});
  }, []);

  const title = narrative?.title || 'SEA AWS Demo';

  const executiveCockpit = (
    <div className="space-y-6">
      <div className="grid grid-cols-1 gap-4 sm:grid-cols-2 lg:grid-cols-4">
        <KPICard title="On-Time Delivery" value="94%" status="warning" />
        <KPICard title="Component Shortage" value="8 SKUs" status="danger" />
        <KPICard title="Lead Time (Avg)" value="6.2 weeks" status="neutral" />
        <KPICard title="Active Suppliers" value="124" status="neutral" />
      </div>
      <div className="grid grid-cols-1 gap-4 lg:grid-cols-2">
        <div className="lg:col-span-1">
          <GeoMap country="malaysia" markers={[{"label": "Penang", "value": "Fab: util 92%", "color": "green", "size": "lg"}, {"label": "Kuala Lumpur", "value": "HQ", "color": "blue", "size": "md"}, {"label": "Johor Bahru", "value": "Southern ops", "color": "green", "size": "md"}]} routes={[]} title="Geographic Overview" height={400} />
        </div>
        <div className="lg:col-span-1 grid grid-cols-1 gap-4">
          <Chart data={data?.timeseries || (() => { const d = []; const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec']; const base = 120; for (let i = 0; i < 12; i++) d.push({ period: months[i], value: Math.round(base + Math.sin(i/2)*40 + (Math.random()*20-10)) }); return d; })()} type="line" xKey="period" yKeys={[{ key: 'value', name: 'OTD %' }]} title="Delivery Performance (Weekly)" />
          <Chart data={data?.categories || [{ category: 'North', count: 82 }, { category: 'Central', count: 74 }, { category: 'South', count: 91 }, { category: 'Highland', count: 68 }, { category: 'Coastal', count: 77 }]} type="bar" xKey="category" yKeys={[{ key: 'count', name: 'SKUs' }]} title="Shortage by Component Type" />
        </div>
      </div>
      <DataTable columns={[
          { key: 'id', header: 'Rank' },
          { key: 'name', header: 'Supplier' },
          { key: 'status', header: 'Status' },
          { key: 'value', header: 'OTD %' },
      ]} data={data?.entities || []} title="Supplier Performance" />
    </div>
  );

  const domainTab1 = (
    <div className="space-y-6">
      <div className="grid grid-cols-1 gap-4 sm:grid-cols-3">
        <KPICard title="Single-Source Risk" value="RM 42M" />
        <KPICard title="Buffer Stock" value="8 days" />
        <KPICard title="Alternatives" value="84%" />
      </div>
      <Chart data={data?.detail || [{ x: 'Mon', y: 24 }, { x: 'Tue', y: 28 }, { x: 'Wed', y: 22 }, { x: 'Thu', y: 31 }, { x: 'Fri', y: 26 }, { x: 'Sat', y: 19 }, { x: 'Sun', y: 23 }]} type="area" xKey="x" yKeys={[{ key: 'y', name: 'Risk Score' }]} title="Supply Risk Assessment" height={400} />
    </div>
  );

  const domainTab2 = (
    <div className="space-y-6">
      <div className="grid grid-cols-1 gap-4 lg:grid-cols-2">
        <Chart data={data?.breakdown || [{ label: 'Zone North', value: 35 }, { label: 'Zone Central', value: 28 }, { label: 'Zone South', value: 22 }, { label: 'Zone East', value: 15 }]} type="pie" xKey="label" yKeys={[{ key: 'value', name: 'RM K/unit' }]} title="Component Cost Trend" />
        <ActionMemo persona={{ name: 'Dato Azman Ibrahim', role: 'VP Supply Chain' }} context={{}} onGenerate={async () => ({ subject: 'Action Required', body: 'AI-generated recommendation based on current data.', urgency: 'HIGH', actions: ['Expedite photoresist shipment (2 days supply left)', 'Qualify backup rare gas supplier', 'Negotiate long-term silicon wafer agreement'] })} />
      </div>
    </div>
  );

  const askAiTab = (
    <div className="h-[600px]">
      <AskAI title="Ask AI" mode="sql" sampleQuestions={['Which materials are below safety stock?', 'Show single-source exposure by category', 'What is lead time variability for top suppliers?']} onSubmit={async (question, mode) => ({ answer: `[Demo Mode] Response to: "${question}" (${mode} mode). Connect to Snowflake for live data.`, sql: mode === 'sql' ? 'SELECT * FROM CURATED.SUMMARY LIMIT 10;' : undefined })} />
    </div>
  );

  const architectureTab = (
    <ArchitectureDiagram
      snowflakeFeatures={['Dynamic Tables (5-min refresh)', 'ML Functions (Forecast + Anomaly)', 'Cortex Search + Agent', 'Semantic View + Intelligence']}
      awsServices={[{ name: 'Amazon S3', role: 'Strategy Docs' }, { name: 'Amazon S3 + Kinesis', role: 'Integration' }, { name: 'Amazon SNS', role: 'Integration' }, { name: 'Amazon QuickSight + Q', role: 'Integration' }]}
    />
  );

  const tabs = [
    { id: 'executive-cockpit', label: 'Executive Cockpit', icon: '📊', content: executiveCockpit },
    { id: 'domain-1', label: 'Risk Management', icon: '📈', content: domainTab1 },
    { id: 'domain-2', label: 'Procurement', icon: '⚡', content: domainTab2 },
    { id: 'ask-ai', label: 'Ask AI', icon: '🤖', content: askAiTab },
    { id: 'architecture', label: 'Architecture', icon: '🏗️', content: architectureTab },
  ];

  return <AppLayout title={title} tabs={tabs} narrative={narrative} />;
}
