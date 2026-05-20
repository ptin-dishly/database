/*
 * OrdersPage.jsx — Página de seguimiento de Pedidos en tiempo real
 *
 * ¿Qué hace esta página?
 * Muestra el estado operativo de todos los pedidos del restaurante:
 *
 * 1. KPIs de pedidos: totales del día, en curso, completados, cancelados,
 *    ítems por pedido, tasa de cancelación
 * 2. Pipeline de estados: un flujo visual que muestra cuántos pedidos hay
 *    en cada etapa (pendiente → confirmado → preparando → servido → cancelado)
 * 3. Feed de pedidos en vivo: lista actualizable de todos los pedidos activos
 *    con su mesa, ítems, camarero y estado (como un monitor de cocina)
 * 4. Pedidos por hora: gráfico de barras apiladas por estado para ver los
 *    patrones de actividad y carga de trabajo
 * 5. Tiempo medio por etapa: cuánto tarda de media un pedido en pasar de
 *    un estado al siguiente (detectar cuellos de botella)
 * 6. Cancelaciones frecuentes: qué platos se cancelan más y por qué
 * 7. Rendimiento por sala: comparar la carga de trabajo de cada sala/zona
 *
 * ¿Por qué es útil para CalBlay?
 * - Operaciones en tiempo real: ver qué pedidos están en cola y cuáles se retrasan
 * - Detectar cuellos de botella: si un pedido tarda mucho en "preparando", la cocina
 *   necesita más recursos
 * - Reducir cancelaciones: identificar platos problemáticos y actuar
 * - Equilibrar carga: si una sala tiene muchos más pedidos, reasignar camareros
 *
 * DATOS SIMULADOS (Mock): Se conectarán a `orders`, `order_items`, `rooms`, `tables`
 */

import { useState, useEffect } from 'react'
import StatCard from '../components/StatCard'
import Panel from '../components/Panel'
import { getOrders, getOrdersHourly, getOrdersRoomPerformance, getOrderStageTimes } from '../api'
import './OrdersPage.css'

/* ═══════════════════════════════════════════════════════════════════════════
   DATOS SIMULADOS (MOCK DATA)
   Fuentes de la BD:
   - orders → estado, timestamps, mesa, camarero
   - order_items → platos en cada pedido, estado individual
   - rooms/tables → para desglosar por sala
   ═══════════════════════════════════════════════════════════════════════════ */

/* Pipeline: cuántos pedidos hay en cada estado ahora mismo */
const pipelineMock = [
  { status: 'pending',   label: 'Pendientes',  count: 8,  color: '#fbbf24' },
  { status: 'confirmed', label: 'Confirmados', count: 12, color: '#60a5fa' },
  { status: 'preparing', label: 'Preparando',  count: 15, color: '#818cf8' },
  { status: 'served',    label: 'Servidos',     count: 98, color: '#34d399' },
  { status: 'cancelled', label: 'Cancelados',   count: 5,  color: '#f87171' },
]

/* Feed de pedidos recientes */
const ordersFeed = [
  { id: '#1247', table: 'Mesa 7',  items: 'Paella Valenciana, Gazpacho × 2',           waiter: 'Carlos M.', time: '14:32', status: 'preparing', itemCount: 3 },
  { id: '#1246', table: 'Mesa 3',  items: 'Entrecot a la Brasa, Ensalada César',        waiter: 'Ana L.',    time: '14:28', status: 'preparing', itemCount: 2 },
  { id: '#1245', table: 'Mesa 12', items: 'Risotto de Setas, Tiramisú × 2',             waiter: 'Pedro S.',  time: '14:25', status: 'confirmed', itemCount: 3 },
  { id: '#1244', table: 'Mesa 5',  items: 'Lubina al Horno, Gazpacho, Tarta Almendras', waiter: 'Carlos M.', time: '14:20', status: 'confirmed', itemCount: 3 },
  { id: '#1243', table: 'Mesa 9',  items: 'Paella Valenciana × 3',                      waiter: 'Ana L.',    time: '14:15', status: 'pending',   itemCount: 3 },
  { id: '#1242', table: 'Mesa 1',  items: 'Ensalada César × 2, Entrecot × 2, Postre × 2', waiter: 'Pedro S.', time: '14:08', status: 'served',  itemCount: 6 },
  { id: '#1241', table: 'Mesa 8',  items: 'Gazpacho, Lubina al Horno',                  waiter: 'Carlos M.', time: '13:55', status: 'served',    itemCount: 2 },
  { id: '#1240', table: 'Mesa 4',  items: 'Risotto de Setas',                           waiter: 'Ana L.',    time: '13:50', status: 'served',    itemCount: 1 },
  { id: '#1239', table: 'Mesa 11', items: 'Paella Valenciana, Tiramisú',                 waiter: 'Pedro S.',  time: '13:42', status: 'cancelled', itemCount: 2 },
  { id: '#1238', table: 'Mesa 2',  items: 'Entrecot a la Brasa × 2, Ensalada César',    waiter: 'Carlos M.', time: '13:35', status: 'served',    itemCount: 3 },
]

/* Pedidos por hora (con desglose por estado) */
const hourlyOrders = [
  { hour: '8',  total: 5,  served: 5,  active: 0 },
  { hour: '9',  total: 12, served: 12, active: 0 },
  { hour: '10', total: 8,  served: 8,  active: 0 },
  { hour: '11', total: 15, served: 15, active: 0 },
  { hour: '12', total: 22, served: 22, active: 0 },
  { hour: '13', total: 35, served: 30, active: 5 },
  { hour: '14', total: 32, served: 12, active: 20 },
  { hour: '15', total: 18, served: 0,  active: 18 },
]

/* Tiempo medio por estado (en minutos) */
const avgTimes = [
  { label: 'Recibido',   time: '0 min',  color: '#fbbf24' },
  { label: 'Confirmado', time: '2 min',  color: '#60a5fa' },
  { label: 'En cocina',  time: '14 min', color: '#818cf8' },
  { label: 'Servido',    time: '18 min', color: '#34d399' },
]

/* Platos más cancelados */
const topCancellations = [
  { name: 'Paella Valenciana',    reason: 'Tiempo de espera excesivo (> 25 min)', count: 3, icon: '🥘' },
  { name: 'Lubina al Horno',     reason: 'Sin stock de lubina fresca',            count: 2, icon: '🐟' },
  { name: 'Tarta de Almendras',  reason: 'Alérgeno detectado tras el pedido',     count: 1, icon: '🎂' },
]

/* Rendimiento por sala */
const roomPerformance = [
  { name: 'Sala Principal',  floor: 'Planta baja', icon: '🏠', color: '#818cf8', orders: 58, avgTime: '16 min', tables: 20 },
  { name: 'Terraza',         floor: 'Exterior',    icon: '☀️', color: '#fbbf24', orders: 42, avgTime: '19 min', tables: 12 },
  { name: 'Sala Privada',    floor: 'Primer piso', icon: '🔒', color: '#34d399', orders: 18, avgTime: '14 min', tables: 8  },
  { name: 'Barra',           floor: 'Planta baja', icon: '🍸', color: '#f472b6', orders: 20, avgTime: '10 min', tables: 10 },
]


function OrdersPage({ establishmentId, date }) {
  const [totalOrders, setTotalOrders] = useState("138")
  const [completedOrders, setCompletedOrders] = useState("98")
  const [cancelledOrders, setCancelledOrders] = useState("5")
  const [trendLabel, setTrendLabel] = useState("vs. ayer")

  const [hourlyOrdersData, setHourlyOrdersData] = useState(hourlyOrders)
  const [roomPerformanceData, setRoomPerformanceData] = useState(roomPerformance)
  const [avgTimesData, setAvgTimesData] = useState(avgTimes)

  useEffect(() => {
    async function loadData() {
      try {
        const realOrders = await getOrders(establishmentId, date)
        if (realOrders && realOrders.length > 0) {
          setTotalOrders(realOrders.length.toString())
          const completed = realOrders.filter(o => o.status === 'served').length
          const cancelled = realOrders.filter(o => o.status === 'cancelled').length
          
          setCompletedOrders(completed.toString())
          setCancelledOrders(cancelled.toString())
          setTrendLabel("Datos reales BD")
        } else {
          setTotalOrders("0")
          setCompletedOrders("0")
          setCancelledOrders("0")
          setTrendLabel("Sin datos")
        }

        const hourly = await getOrdersHourly(establishmentId, date)
        if (hourly && hourly.length > 0) {
          setHourlyOrdersData(hourly.map(h => ({
            hour: h.hour_of_day.toString(),
            total: Number(h.total_orders),
            served: Number(h.served_orders),
            active: Number(h.active_orders)
          })))
        } else {
          setHourlyOrdersData([])
        }

        const roomPerf = await getOrdersRoomPerformance(establishmentId, date)
        if (roomPerf && roomPerf.length > 0) {
          setRoomPerformanceData(roomPerf.map((r, i) => ({
            name: r.room_name,
            floor: `Planta ${r.floor || 0}`,
            icon: roomPerformance[i % roomPerformance.length]?.icon || '🏠',
            color: roomPerformance[i % roomPerformance.length]?.color || '#818cf8',
            orders: Number(r.total_orders),
            avgTime: '15 min',
            tables: Number(r.total_tables)
          })))
        } else {
          setRoomPerformanceData([])
        }

        const stageTimes = await getOrderStageTimes(establishmentId, date)
        if (stageTimes && stageTimes.length > 0) {
          // Find minutes for each stage we care about
          const getMins = (status) => {
            const found = stageTimes.find(s => s.status === status)
            return found ? `${found.avg_minutes} min` : '-'
          }
          
          setAvgTimesData([
            { label: 'Recibido',   time: getMins('pending'),  color: '#fbbf24' },
            { label: 'Confirmado', time: getMins('confirmed'),  color: '#60a5fa' },
            { label: 'En cocina',  time: getMins('preparing'), color: '#818cf8' },
            { label: 'Servido',    time: getMins('served'), color: '#34d399' },
          ])
        } else {
          setAvgTimesData([
            { label: 'Recibido',   time: '-', color: '#fbbf24' },
            { label: 'Confirmado', time: '-', color: '#60a5fa' },
            { label: 'En cocina',  time: '-', color: '#818cf8' },
            { label: 'Servido',    time: '-', color: '#34d399' },
          ])
        }
      } catch (err) {
        console.error("Error loading orders page data", err)
      }
    }
    loadData()
  }, [establishmentId, date])

  /* Mapa de colores y etiquetas para los badges de estado */
  const statusConfig = {
    pending:   { label: 'Pendiente',  class: 'badge-warning' },
    confirmed: { label: 'Confirmado', class: 'badge-info' },
    preparing: { label: 'Preparando', class: 'badge-primary' },
    served:    { label: 'Servido',    class: 'badge-success' },
    cancelled: { label: 'Cancelado',  class: 'badge-danger' },
  }

  /* Valor máximo para escalar las barras del gráfico horario */
  const maxHourly = Math.max(...hourlyOrdersData.map(h => h.total), 1)

  return (
    <div className="orders-page">

      {/* ═══════════════════════════════════════════════════════════════
          SECCIÓN 1: KPIs de Pedidos
          Fuente BD: COUNT/AVG de orders con filtros por estado y fecha
          ═══════════════════════════════════════════════════════════════ */}
      <div className="stats-grid">
        <StatCard
          icon="📋"
          label="Pedidos Hoy"
          value={totalOrders}
          trend="up"
          trendValue="+18"
          trendLabel={trendLabel}
          accentColor="#818cf8"
        />
        <StatCard
          icon="🔄"
          label="En Curso Ahora"
          value="35"
          trend="neutral"
          trendValue="pendientes + cocina"
          accentColor="#60a5fa"
        />
        <StatCard
          icon="✅"
          label="Completados"
          value={completedOrders}
          trend="up"
          trendValue="+12"
          trendLabel={trendLabel}
          accentColor="#34d399"
        />
        <StatCard
          icon="❌"
          label="Cancelados"
          value={cancelledOrders}
          trend="down"
          trendValue="-3"
          trendLabel={trendLabel}
          accentColor="#f87171"
        />
        <StatCard
          icon="🍽️"
          label="Ítems por Pedido"
          value="2.7"
          trend="up"
          trendValue="+0.3"
          trendLabel="vs. media"
          accentColor="#a78bfa"
        />
        <StatCard
          icon="📉"
          label="Tasa Cancelación"
          value="3.6%"
          trend="down"
          trendValue="-1.2 pp"
          trendLabel="vs. semana pasada"
          accentColor="#fbbf24"
        />
      </div>

      {/* ═══════════════════════════════════════════════════════════════
          SECCIÓN 2: Pipeline de estados
          Muestra de forma visual cuántos pedidos hay en cada etapa.
          Fuente BD: COUNT(orders) GROUP BY status
          ═══════════════════════════════════════════════════════════════ */}
      <Panel
        title="Pipeline de Pedidos"
        icon="🔄"
        subtitle="Estado actual de todos los pedidos — en tiempo real"
      >
        <div className="pipeline-container">
          {pipelineMock.map((stage, i) => (
            <>
              <div key={stage.status} className="pipeline-stage">
                <div className="pipeline-stage-count" style={{ color: stage.color }}>
                  {stage.count}
                </div>
                <div className="pipeline-stage-label">{stage.label}</div>
                <div className="pipeline-stage-bar" style={{ background: stage.color }} />
              </div>
              {i < pipelineMock.length - 1 && (
                <div key={`arrow-${i}`} className="pipeline-arrow">→</div>
              )}
            </>
          ))}
        </div>
      </Panel>

      {/* ═══════════════════════════════════════════════════════════════
          SECCIÓN 3: Feed de pedidos en vivo + Pedidos por hora
          El feed es como un monitor de cocina: lista todos los pedidos
          recientes con su estado, mesa y camarero.
          Fuente BD: SELECT * FROM orders ORDER BY created_at DESC LIMIT 20
          ═══════════════════════════════════════════════════════════════ */}
      <div className="panels-row">
        {/* Feed en vivo */}
        <Panel
          title="Pedidos Recientes"
          icon="📡"
          subtitle="Últimas horas — scroll para ver más"
        >
          <div className="orders-feed">
            {ordersFeed.map((order) => (
              <div key={order.id} className={`order-card status-${order.status}`}>
                <span className="order-card-id">{order.id}</span>
                <div className="order-card-info">
                  <div className="order-card-items">{order.items}</div>
                  <div className="order-card-meta">
                    <span>👤 {order.waiter}</span>
                    <span>🍽️ {order.itemCount} ítems</span>
                  </div>
                </div>
                <span className="order-card-table">{order.table}</span>
                <span className="order-card-time">{order.time}</span>
                <div className="order-card-status">
                  <span className={`badge ${statusConfig[order.status].class}`}>
                    {statusConfig[order.status].label}
                  </span>
                </div>
              </div>
            ))}
          </div>
        </Panel>

        {/* Pedidos por hora */}
        <Panel
          title="Pedidos por Hora"
          icon="📊"
          subtitle="Servidos vs. en curso"
        >
          <div className="orders-hourly-chart">
            {hourlyOrdersData.map((h) => (
              <div key={h.hour} className="orders-hourly-bar-wrapper">
                <span className="orders-hourly-value">{h.total}</span>
                <div style={{ display: 'flex', flexDirection: 'column', width: '100%', maxWidth: '28px', gap: '1px' }}>
                  {h.active > 0 && (
                    <div
                      className="orders-hourly-bar"
                      style={{
                        height: `${(h.active / maxHourly) * 140}px`,
                        background: 'linear-gradient(to top, var(--accent-warning), rgba(251, 191, 36, 0.4))',
                        borderRadius: '4px 4px 0 0',
                      }}
                      title={`${h.hour}:00 — ${h.active} en curso`}
                    />
                  )}
                  {h.served > 0 && (
                    <div
                      className="orders-hourly-bar"
                      style={{
                        height: `${(h.served / maxHourly) * 140}px`,
                        background: 'linear-gradient(to top, var(--accent-secondary), rgba(52, 211, 153, 0.4))',
                        borderRadius: h.active > 0 ? '0' : '4px 4px 0 0',
                      }}
                      title={`${h.hour}:00 — ${h.served} servidos`}
                    />
                  )}
                </div>
                <span className="orders-hourly-label">{h.hour}h</span>
              </div>
            ))}
          </div>
          <div className="chart-legend">
            <div className="chart-legend-item">
              <div className="chart-legend-dot" style={{ background: 'var(--accent-secondary)' }}></div>
              Servidos
            </div>
            <div className="chart-legend-item">
              <div className="chart-legend-dot" style={{ background: 'var(--accent-warning)' }}></div>
              En curso
            </div>
          </div>

          {/* Tiempo medio por etapa */}
          <div style={{ marginTop: 'var(--space-xl)', paddingTop: 'var(--space-lg)', borderTop: '1px solid var(--border-subtle)' }}>
            <div style={{ fontSize: 'var(--font-size-sm)', fontWeight: 600, color: 'var(--text-primary)', marginBottom: 'var(--space-md)' }}>
              ⏱️ Tiempo medio por etapa
            </div>
            <div className="time-pipeline">
              {avgTimesData.map((step, i) => (
                <div key={step.label} className="time-pipeline-step">
                  <div className="time-pipeline-dot" style={{ background: step.color }} />
                  {i < avgTimesData.length - 1 && <div className="time-pipeline-connector" />}
                  <span className="time-pipeline-time">{step.time}</span>
                  <span className="time-pipeline-label">{step.label}</span>
                </div>
              ))}
            </div>
          </div>
        </Panel>
      </div>

      {/* ═══════════════════════════════════════════════════════════════
          SECCIÓN 4: Cancelaciones + Rendimiento por sala
          Fuente BD: orders WHERE status='cancelled', GROUP BY room_id
          ═══════════════════════════════════════════════════════════════ */}
      <div className="panels-row">
        {/* Cancelaciones frecuentes */}
        <Panel
          title="Cancelaciones Frecuentes"
          icon="🚫"
          subtitle="Platos más cancelados hoy — detectar problemas"
        >
          <div className="cancellation-list">
            {topCancellations.map((item) => (
              <div key={item.name} className="cancellation-item">
                <span className="cancellation-item-icon">{item.icon}</span>
                <div className="cancellation-item-info">
                  <div className="cancellation-item-name">{item.name}</div>
                  <div className="cancellation-item-reason">{item.reason}</div>
                </div>
                <span className="cancellation-item-count">×{item.count}</span>
              </div>
            ))}
          </div>

          <div className="insight-box" style={{ marginTop: 'var(--space-lg)' }}>
            💡 <strong>Acción sugerida:</strong> La Paella Valenciana tiene el mayor ratio de
            cancelación por tiempo de espera. Considerar pre-preparar la base durante el mise en place
            para reducir el tiempo de servicio.
          </div>
        </Panel>

        {/* Rendimiento por sala */}
        <Panel
          title="Rendimiento por Sala"
          icon="🏠"
          subtitle="Comparativa de carga de trabajo"
        >
          <div className="room-performance">
            {roomPerformanceData.map((room) => (
              <div key={room.name} className="room-row">
                <div className="room-icon" style={{ background: `${room.color}15`, border: `1px solid ${room.color}30` }}>
                  {room.icon}
                </div>
                <div className="room-info">
                  <div className="room-name">{room.name}</div>
                  <div className="room-detail">{room.floor} · {room.tables} mesas</div>
                </div>
                <div className="room-stats">
                  <div className="room-stat">
                    <div className="room-stat-value">{room.orders}</div>
                    <div className="room-stat-label">pedidos</div>
                  </div>
                  <div className="room-stat">
                    <div className="room-stat-value">{room.avgTime}</div>
                    <div className="room-stat-label">t. medio</div>
                  </div>
                </div>
              </div>
            ))}
          </div>
        </Panel>
      </div>
    </div>
  )
}

export default OrdersPage
