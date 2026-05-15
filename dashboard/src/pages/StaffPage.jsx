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

import StatCard from '../components/StatCard'
import Panel from '../components/Panel'
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

function StaffPage() {
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
          value="4"
          trend="neutral"
          trendValue="1 zona sin asignar"
          trendLabel=""
          accentColor="#3b82f6"
        />
        <StatCard
          icon="🍽️"
          label="Pedidos Atendidos"
          value="123"
          trend="up"
          trendValue="+14"
          trendLabel="vs. ayer"
          accentColor="#10b981"
        />
        <StatCard
          icon="💶"
          label="Ticket Medio / Camarero"
          value="34.15€"
          trend="up"
          trendValue="+2.10€"
          trendLabel="por mejora en upselling"
          accentColor="#8b5cf6"
        />
        <StatCard
          icon="✅"
          label="Alertas Resueltas"
          value="100%"
          trend="up"
          trendValue="12 alertas"
          trendLabel="gestionadas hoy"
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
              {zoneAssignments.map(zone => (
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
              {recentActivity.map(item => (
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
              {staffPerformance.map(staff => (
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
