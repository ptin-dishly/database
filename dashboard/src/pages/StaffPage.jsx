/*
 * StaffPage.jsx — Página de Personal
 *
 * ¿Qué hace esta página?
 * Proporciona información sobre el rendimiento del equipo de sala y su asignación:
 *
 * 1. KPIs de Personal: personal activo, pedidos atendidos, ticket medio generado, alertas resueltas.
 * 2. Asignación de Zonas: qué camarero está asignado a qué sala/zona y el estado de carga.
 * 3. Ranking de Rendimiento: clasificación de camareros basada en los ingresos que han generado hoy.
 */

import { useState, useEffect } from 'react'
import StatCard from '../components/StatCard'
import Panel from '../components/Panel'
import { getStaff, getStaffPerformance, getStaffZones, getStaffActivityLog, getAllergenAlerts } from '../api'
import './StaffPage.css'

/* ═══════════════════════════════════════════════════════════════════════════
   DATOS SIMULADOS (MOCK DATA)
   ═══════════════════════════════════════════════════════════════════════════ */

/* Asignación de Zonas (waiter_zones) */
const zoneAssignments = [
  { id: 1, room: 'Salón Principal', waiter: 'Ana García', avatar: 'AG', tablesAssigned: 8, activeTables: 6, status: 'busy' },
  { id: 2, room: 'Terraza Norte', waiter: 'Carlos Torres', avatar: 'CT', tablesAssigned: 6, activeTables: 2, status: 'normal' },
  { id: 3, room: 'Terraza Sur', waiter: 'Miguel Ángel', avatar: 'MA', tablesAssigned: 6, activeTables: 5, status: 'busy' },
  { id: 4, room: 'Reservado VIP', waiter: 'Laura Sánchez', avatar: 'LS', tablesAssigned: 2, activeTables: 2, status: 'normal' },
  { id: 5, room: 'Barra', waiter: 'Sin asignar', avatar: '?', tablesAssigned: 10, activeTables: 0, status: 'unassigned' },
]

/* Ranking de Rendimiento (Orders + OrderItems) */
const staffPerformance = [
  { rank: 1, id: 'w1', name: 'Ana García',     orders: 42, revenue: 1450.50, upselling: '+12%', avgTime: '14m' },
  { rank: 2, id: 'w3', name: 'Miguel Ángel',   orders: 38, revenue: 1280.00, upselling: '+8%',  avgTime: '16m' },
  { rank: 3, id: 'w2', name: 'Carlos Torres',  orders: 29, revenue: 890.20,  upselling: '-2%',  avgTime: '12m' },
  { rank: 4, id: 'w4', name: 'Laura Sánchez',  orders: 14, revenue: 580.00,  upselling: '+5%',  avgTime: '18m' },
]

/* Registro de Actividad Reciente (Audit Log) */
const recentActivity = [
  { id: 1, time: '14:32', user: 'Ana G.', action: 'Resolvió alerta de alérgenos (Mesa 3)', type: 'alert' },
  { id: 2, time: '14:15', user: 'Carlos T.', action: 'Canceló pedido #1042 (Error cocina)', type: 'warning' },
  { id: 3, time: '14:05', user: 'Admin', action: 'Reasignó Terraza Sur a Miguel A.', type: 'info' },
  { id: 4, time: '13:50', user: 'Laura S.', action: 'Tomó pedido VIP #1041 (280€)', type: 'success' },
]

function StaffPage({ establishmentId, date }) {
  const [staffCount, setStaffCount] = useState("0")
  const [trendLabel, setTrendLabel] = useState("")
  const [staffPerformanceData, setStaffPerformanceData] = useState(staffPerformance)
  const [zoneAssignmentsData, setZoneAssignmentsData] = useState(zoneAssignments)
  const [recentActivityData, setRecentActivityData] = useState(recentActivity)
  
  // KPIs
  const [totalOrders, setTotalOrders] = useState("0")
  const [avgTicket, setAvgTicket] = useState("0.00€")
  const [alertsResolved, setAlertsResolved] = useState("0%")

  useEffect(() => {
    async function loadData() {
      try {
        const staff = await getStaff()
        if (staff && staff.length > 0) {
          const waiters = staff.filter(s => s.role === 'waiter')
          setStaffCount(waiters.length.toString())
          setTrendLabel("Camareros en BD")
        } else {
          setStaffCount("0")
          setTrendLabel("Sin datos")
        }

        const perf = await getStaffPerformance(establishmentId, date)
        if (perf && perf.length > 0) {
          let totOrders = 0;
          let totRev = 0;
          const sortedPerf = [...perf].sort((a, b) => Number(b.revenue_generated) - Number(a.revenue_generated))
          setStaffPerformanceData(sortedPerf.map((p, i) => {
            const ords = Number(p.orders_served);
            const rev = Number(p.revenue_generated);
            totOrders += ords;
            totRev += rev;
            return {
              rank: i + 1,
              id: p.user_id,
              name: p.waiter_name,
              orders: ords,
              revenue: rev,
              upselling: staffPerformance[i % staffPerformance.length]?.upselling || '+0%',
              avgTime: staffPerformance[i % staffPerformance.length]?.avgTime || '15m'
            }
          }))
          
          setTotalOrders(totOrders.toString());
          if (totOrders > 0) {
            setAvgTicket((totRev / totOrders).toFixed(2) + '€');
          }
        } else {
          setStaffPerformanceData([])
          setTotalOrders("0")
          setAvgTicket("0.00€")
        }

        const zones = await getStaffZones(establishmentId, date)
        if (zones && zones.length > 0) {
          setZoneAssignmentsData(zones.map(z => ({
            id: z.id,
            room: z.room_name,
            waiter: z.waiter_name,
            avatar: z.waiter_name.split(' ').map(n=>n[0]).join('').substring(0,2).toUpperCase(),
            tablesAssigned: Number(z.tables_assigned),
            activeTables: Number(z.active_tables),
            status: z.status
          })))
        } else {
          setZoneAssignmentsData([])
        }

        const activity = await getStaffActivityLog(establishmentId, date)
        if (activity && activity.length > 0) {
          setRecentActivityData(activity.map(a => ({
            id: a.id,
            time: new Date(a.time).toLocaleTimeString([], {hour: '2-digit', minute:'2-digit'}),
            user: a.user_name || 'Sistema',
            action: a.action,
            type: a.type
          })))
        } else {
          setRecentActivityData([])
        }

        const alerts = await getAllergenAlerts(establishmentId, date)
        if (alerts && alerts.length > 0) {
          const resolved = alerts.filter(a => a.is_resolved).length;
          setAlertsResolved(`${Math.round((resolved / alerts.length) * 100)}%`)
        } else {
          setAlertsResolved("0%")
        }
      } catch (err) {
        console.error("Error fetching staff", err)
      }
    }
    loadData()
  }, [establishmentId, date])

  const getRankClass = (rank) => {
    if (rank === 1) return 'gold'
    if (rank === 2) return 'silver'
    if (rank === 3) return 'bronze'
    return ''
  }

  const getStatusBadge = (status) => {
    switch (status) {
      case 'busy': return <span className="zone-badge busy">Alta Carga</span>
      case 'normal': return <span className="zone-badge normal">Carga Media</span>
      case 'unassigned': return <span className="zone-badge unassigned">Sin Asignar</span>
      default: return null
    }
  }

  return (
    <div className="staff-page">

      {/* ═══════════════════════════════════════════════════════════════
          SECCIÓN 1: KPIs de Personal
          ═══════════════════════════════════════════════════════════════ */}
      <div className="stats-grid">
        <StatCard
          icon="👥"
          label="Personal en Turno"
          value={staffCount}
          trend="neutral"
          trendValue="1 zona sin asignar"
          trendLabel={trendLabel}
          accentColor="#3b82f6"
        />
        <StatCard
          icon="🍽️"
          label="Pedidos Atendidos"
          value={totalOrders}
          trend="neutral"
          trendValue="Tiempo real"
          trendLabel={trendLabel}
          accentColor="#10b981"
        />
        <StatCard
          icon="💶"
          label="Ticket Medio / Pedido"
          value={avgTicket}
          trend="neutral"
          trendValue="Tiempo real"
          trendLabel={trendLabel}
          accentColor="#8b5cf6"
        />
        <StatCard
          icon="✅"
          label="Alertas Resueltas"
          value={alertsResolved}
          trend="neutral"
          trendValue="Tiempo real"
          trendLabel={trendLabel}
          accentColor="#14b8a6"
        />
      </div>

      {/* ═══════════════════════════════════════════════════════════════
          SECCIÓN 2: Paneles Detallados
          ═══════════════════════════════════════════════════════════════ */}
      <div className="panels-row-staff">
        
        {/* Lado Izquierdo: Zonas y Actividad */}
        <div className="staff-left-col">
          {/* Asignación de Zonas */}
          <Panel
            title="Asignación de Zonas"
            icon="🗺️"
            subtitle="Carga de trabajo por sala"
          >
            <div className="zone-assignments-list">
              {zoneAssignmentsData.map(zone => (
                <div key={zone.id} className={`zone-card ${zone.status}`}>
                  <div className="zone-info">
                    <h4 className="zone-name">{zone.room}</h4>
                    <div className="zone-stats">
                      Mesas Activas: <strong>{zone.activeTables}/{zone.tablesAssigned}</strong>
                    </div>
                  </div>
                  
                  <div className="zone-waiter">
                    <div className="waiter-avatar">{zone.avatar}</div>
                    <div className="waiter-details">
                      <span className="waiter-name">{zone.waiter}</span>
                      {getStatusBadge(zone.status)}
                    </div>
                  </div>
                </div>
              ))}
            </div>
          </Panel>

          {/* Actividad Reciente */}
          <Panel
            title="Actividad Relevante"
            icon="⚡"
            subtitle="Últimas acciones del personal"
          >
            <div className="activity-timeline">
              {recentActivityData.map(item => (
                <div key={item.id} className="activity-item">
                  <div className="activity-time">{item.time}</div>
                  <div className={`activity-dot ${item.type}`}></div>
                  <div className="activity-content">
                    <span className="activity-user">{item.user}</span>
                    <span className="activity-action">{item.action}</span>
                  </div>
                </div>
              ))}
            </div>
          </Panel>
        </div>

        {/* Lado Derecho: Ranking */}
        <div className="staff-right-col">
          <Panel
            title="Ranking de Rendimiento"
            icon="🏆"
            subtitle="Camareros clasificados por ingresos generados"
          >
            <div className="performance-ranking">
              {staffPerformanceData.map(staff => (
                <div key={staff.id} className="ranking-card">
                  <div className="ranking-left">
                    <div className={`ranking-position panel-list-item-rank ${getRankClass(staff.rank)}`}>
                      {staff.rank}
                    </div>
                    <div className="ranking-waiter-info">
                      <h4 className="ranking-name">{staff.name}</h4>
                      <span className="ranking-orders">{staff.orders} pedidos completados</span>
                    </div>
                  </div>
                  
                  <div className="ranking-right">
                    <div className="ranking-revenue">
                      {staff.revenue.toLocaleString('es-ES', { minimumFractionDigits: 2 })}€
                    </div>
                    <div className="ranking-metrics">
                      <span className="metric tooltip" data-tooltip="Incremento medio vs ticket base">
                        📈 {staff.upselling}
                      </span>
                      <span className="metric tooltip" data-tooltip="Tiempo medio de servicio">
                        ⏱️ {staff.avgTime}
                      </span>
                    </div>
                  </div>
                </div>
              ))}
            </div>
            
            <div className="insight-box mt-4">
              💡 <strong>Insights de Rendimiento:</strong> Ana García está liderando las ventas hoy, 
              destacando un +12% en upselling (venta sugestiva de postres y bebidas). Podría ser 
              buen momento para reconocer su esfuerzo en el próximo briefing.
            </div>
          </Panel>
        </div>

      </div>
    </div>
  )
}

export default StaffPage
