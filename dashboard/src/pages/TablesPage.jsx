/*
 * TablesPage.jsx — Página de Ocupación de Mesas
 *
 * ¿Qué hace esta página?
 * Proporciona una visión en tiempo real y estadísticas de la ocupación del restaurante:
 *
 * 1. KPIs de ocupación: mesas ocupadas, libres, reservadas, capacidad actual.
 * 2. Estado actual de las mesas: listado visual de mesas con su estado (libre, ocupada, reservada) y tiempo.
 * 3. Distribución por tamaño: qué tipo de mesas están más demandadas.
 */

import StatCard from '../components/StatCard'
import Panel from '../components/Panel'
import './TablesPage.css'

/* ═══════════════════════════════════════════════════════════════════════════
   DATOS SIMULADOS (MOCK DATA)
   ═══════════════════════════════════════════════════════════════════════════ */

/* Estado actual de las mesas */
const tablesStatus = [
  { id: 1, name: 'Mesa 1',  capacity: 2, status: 'occupied', diners: 2, timeElapsed: '45 min',  waiter: 'Ana G.' },
  { id: 2, name: 'Mesa 2',  capacity: 2, status: 'free',     diners: 0, timeElapsed: '-',       waiter: '-' },
  { id: 3, name: 'Mesa 3',  capacity: 4, status: 'reserved', diners: 4, timeElapsed: '14:30',   waiter: '-' },
  { id: 4, name: 'Mesa 4',  capacity: 4, status: 'occupied', diners: 3, timeElapsed: '1h 15m',  waiter: 'Carlos T.' },
  { id: 5, name: 'Mesa 5',  capacity: 6, status: 'occupied', diners: 6, timeElapsed: '20 min',  waiter: 'Ana G.' },
  { id: 6, name: 'Mesa 6',  capacity: 2, status: 'free',     diners: 0, timeElapsed: '-',       waiter: '-' },
  { id: 7, name: 'Mesa 7',  capacity: 8, status: 'occupied', diners: 7, timeElapsed: '1h 50m',  waiter: 'Miguel A.' },
  { id: 8, name: 'Mesa 8',  capacity: 4, status: 'reserved', diners: 2, timeElapsed: '15:00',   waiter: '-' },
  { id: 9, name: 'Mesa 9',  capacity: 2, status: 'occupied', diners: 2, timeElapsed: '5 min',   waiter: 'Carlos T.' },
  { id: 10, name: 'Terraza 1', capacity: 4, status: 'free',  diners: 0, timeElapsed: '-',       waiter: '-' },
  { id: 11, name: 'Terraza 2', capacity: 4, status: 'occupied', diners: 4, timeElapsed: '30 min', waiter: 'Miguel A.' },
  { id: 12, name: 'Terraza 3', capacity: 6, status: 'free',  diners: 0, timeElapsed: '-',       waiter: '-' },
]

/* Distribución por tamaño de mesa */
const tableSizeDistribution = [
  { size: '2 pax', total: 15, occupied: 12, pct: 80, color: '#60a5fa' },
  { size: '4 pax', total: 20, occupied: 14, pct: 70, color: '#34d399' },
  { size: '6 pax', total: 8,  occupied: 6,  pct: 75, color: '#fbbf24' },
  { size: '8+ pax', total: 4, occupied: 1,  pct: 25, color: '#f472b6' },
]

function TablesPage() {
  const getStatusColor = (status) => {
    switch (status) {
      case 'occupied': return '#ef4444' // Rojo
      case 'free': return '#10b981' // Verde
      case 'reserved': return '#f59e0b' // Amarillo
      default: return '#6b7280' // Gris
    }
  }

  const getStatusLabel = (status) => {
    switch (status) {
      case 'occupied': return 'Ocupada'
      case 'free': return 'Libre'
      case 'reserved': return 'Reservada'
      default: return 'Desconocido'
    }
  }

  return (
    <div className="tables-page">

      {/* ═══════════════════════════════════════════════════════════════
          SECCIÓN 1: KPIs de Ocupación
          ═══════════════════════════════════════════════════════════════ */}
      <div className="stats-grid">
        <StatCard
          icon="🪑"
          label="Ocupación Actual"
          value="68%"
          trend="up"
          trendValue="+12%"
          trendLabel="vs. ayer misma hora"
          accentColor="#3b82f6"
        />
        <StatCard
          icon="✅"
          label="Mesas Libres"
          value="14"
          trend="down"
          trendValue="-3"
          trendLabel="en la última hora"
          accentColor="#10b981"
        />
        <StatCard
          icon="📅"
          label="Reservas Próximas"
          value="8"
          trend="neutral"
          trendValue="Próximas 2h"
          trendLabel=""
          accentColor="#f59e0b"
        />
        <StatCard
          icon="👥"
          label="Comensales Actuales"
          value="84"
          trend="up"
          trendValue="+15"
          trendLabel="vs. media semanal"
          accentColor="#8b5cf6"
        />
        <StatCard
          icon="⏳"
          label="Tiempo Medio/Mesa"
          value="1h 25m"
          trend="down"
          trendValue="-5m"
          trendLabel="vs. media mensual"
          accentColor="#ec4899"
        />
        <StatCard
          icon="🔄"
          label="Rotación (Turnos)"
          value="1.8"
          trend="up"
          trendValue="+0.2"
          trendLabel="vs. ayer"
          accentColor="#f97316"
        />
      </div>

      {/* ═══════════════════════════════════════════════════════════════
          SECCIÓN 2: Paneles Detallados
          ═══════════════════════════════════════════════════════════════ */}
      <div className="panels-row-tables">
        {/* Mapa / Listado de Mesas */}
        <Panel
          title="Estado de Mesas (En Vivo)"
          icon="🗺️"
          subtitle="Vista general de la sala y terraza"
        >
          <div className="tables-grid-view">
            {tablesStatus.map(table => (
              <div key={table.id} className={`table-card status-${table.status}`}>
                <div className="table-card-header">
                  <span className="table-name">{table.name}</span>
                  <span className="table-capacity">👤 {table.capacity}</span>
                </div>
                <div className="table-card-body">
                  <div className="table-status-indicator">
                    <div 
                      className="status-dot" 
                      style={{ backgroundColor: getStatusColor(table.status) }}
                    />
                    <span>{getStatusLabel(table.status)}</span>
                  </div>
                  {table.status === 'occupied' && (
                    <div className="table-details">
                      <div>Comensales: {table.diners}</div>
                      <div>Tiempo: {table.timeElapsed}</div>
                      <div>Camarero: {table.waiter}</div>
                    </div>
                  )}
                  {table.status === 'reserved' && (
                    <div className="table-details">
                      <div>Hora: {table.timeElapsed}</div>
                      <div>Pax: {table.diners}</div>
                    </div>
                  )}
                  {table.status === 'free' && (
                    <div className="table-details empty">
                      Lista para sentar
                    </div>
                  )}
                </div>
              </div>
            ))}
          </div>
        </Panel>

        {/* Panel lateral con métricas adicionales */}
        <div className="side-panels">
          <Panel
            title="Ocupación por Tamaño"
            icon="📊"
            subtitle="Demanda de mesas por capacidad"
          >
            <div className="table-size-distribution">
              {tableSizeDistribution.map(item => (
                <div key={item.size} className="size-row">
                  <div className="size-label">{item.size}</div>
                  <div className="size-bar-track">
                    <div 
                      className="size-bar-fill" 
                      style={{ width: `${item.pct}%`, backgroundColor: item.color }}
                    />
                  </div>
                  <div className="size-stats">
                    {item.occupied}/{item.total} ({item.pct}%)
                  </div>
                </div>
              ))}
            </div>
            <div className="insight-box mt-4">
              💡 <strong>Dato clave:</strong> Las mesas de 2 personas están al 80% de ocupación. 
              Podría ser necesario desdoblar mesas de 4 si continúan llegando parejas.
            </div>
          </Panel>

          <Panel
            title="Avisos Importantes"
            icon="🔔"
            subtitle="Alertas automáticas del sistema"
          >
            <ul className="alerts-list">
              <li className="alert-item warning">
                <span className="alert-icon">⚠️</span>
                <span>La <strong>Mesa 7</strong> lleva ocupada más de 1h 45m.</span>
              </li>
              <li className="alert-item info">
                <span className="alert-icon">ℹ️</span>
                <span>Llegada inminente: Reserva para 4 pax (Mesa 3) a las 14:30.</span>
              </li>
              <li className="alert-item success">
                <span className="alert-icon">✅</span>
                <span>Terraza 1 y 3 recién limpiadas y listas.</span>
              </li>
            </ul>
          </Panel>
        </div>
      </div>
    </div>
  )
}

export default TablesPage
