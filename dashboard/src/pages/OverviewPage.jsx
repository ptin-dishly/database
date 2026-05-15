/*
 * OverviewPage.jsx — Página principal "Vista General" del Dashboard
 *
 * ¿Qué hace esta página?
 * Es la primera pantalla que ves al abrir el dashboard. Muestra un resumen
 * rápido de todas las métricas clave del día:
 * - Tarjetas KPI arriba (pedidos, ingresos, ocupación, alertas)
 * - Top 5 platos más pedidos
 * - Anillo de ocupación de mesas
 * - Alertas de alérgenos recientes
 * - Actividad por horas
 *
 * IMPORTANTE: Todos los datos son SIMULADOS (mock data) por ahora.
 * En la siguiente fase, estos datos se conectarán a la base de datos real.
 */

import StatCard from '../components/StatCard'
import Panel from '../components/Panel'
import './OverviewPage.css'

/* ── Datos simulados (Mock Data) ──
   Estos datos imitan lo que la base de datos nos devolvería en tiempo real.
   Los mantenemos aquí temporalmente para diseñar la interfaz. */

const mockStats = [
  {
    icon: '🍽️',
    label: 'Pedidos Hoy',
    value: '147',
    trend: 'up',
    trendValue: '+12.5%',
    trendLabel: 'vs. ayer',
    accentColor: '#818cf8',
  },
  {
    icon: '💰',
    label: 'Ingresos del Día',
    value: '4.230€',
    trend: 'up',
    trendValue: '+8.3%',
    trendLabel: 'vs. ayer',
    accentColor: '#34d399',
  },
  {
    icon: '🪑',
    label: 'Ocupación Actual',
    value: '82%',
    trend: 'up',
    trendValue: '+5.1%',
    trendLabel: 'vs. media semanal',
    accentColor: '#60a5fa',
  },
  {
    icon: '⚠️',
    label: 'Alertas Alérgenos',
    value: '3',
    trend: 'down',
    trendValue: '-40%',
    trendLabel: 'vs. ayer',
    accentColor: '#fbbf24',
  },
  {
    icon: '⏱️',
    label: 'Tiempo Medio Servicio',
    value: '18 min',
    trend: 'down',
    trendValue: '-2 min',
    trendLabel: 'vs. media',
    accentColor: '#a78bfa',
  },
  {
    icon: '👥',
    label: 'Comensales Hoy',
    value: '312',
    trend: 'up',
    trendValue: '+15.2%',
    trendLabel: 'vs. viernes pasado',
    accentColor: '#f472b6',
  },
]

const topDishes = [
  { rank: 1, name: 'Paella Valenciana',    category: 'Primer Plato', orders: 34, pct: 100 },
  { rank: 2, name: 'Entrecot a la Brasa',  category: 'Segundo Plato', orders: 28, pct: 82 },
  { rank: 3, name: 'Tiramisú Casero',      category: 'Postre', orders: 25, pct: 73 },
  { rank: 4, name: 'Gazpacho Andaluz',     category: 'Entrante', orders: 22, pct: 65 },
  { rank: 5, name: 'Lubina al Horno',      category: 'Segundo Plato', orders: 19, pct: 56 },
]

const allergenAlerts = [
  { time: '14:23', comensal: 'María G.', allergen: 'Gluten', dish: 'Pan de Hogaza', severity: 'alta', resolved: false },
  { time: '13:45', comensal: 'Carlos P.', allergen: 'Lactosa', dish: 'Salsa Bechamel', severity: 'media', resolved: true },
  { time: '12:10', comensal: 'Ana R.', allergen: 'Frutos Secos', dish: 'Tarta de Almendras', severity: 'alta', resolved: true },
]

const hourlyActivity = [35, 28, 42, 55, 70, 85, 92, 88, 95, 78, 65, 48, 30, 22, 18]

function OverviewPage() {
  /* Datos para el anillo de ocupación */
  const occupancyPct = 82
  /* 408 es la circunferencia del círculo SVG (2 * π * radio 65) */
  const strokeOffset = 408 - (408 * occupancyPct) / 100

  /* Función para dar la clase de medalla según el ranking */
  const rankClass = (rank) => {
    if (rank === 1) return 'gold'
    if (rank === 2) return 'silver'
    if (rank === 3) return 'bronze'
    return ''
  }

  return (
    <div className="overview-page">
      {/* ═══════════════════════════════════════════════════════════════
          SECCIÓN 1: Tarjetas KPI (números grandes arriba)
          ═══════════════════════════════════════════════════════════════ */}
      <div className="stats-grid">
        {mockStats.map((stat, i) => (
          <StatCard key={i} {...stat} />
        ))}
      </div>

      {/* ═══════════════════════════════════════════════════════════════
          SECCIÓN 2: Top platos + Ocupación (dos paneles lado a lado)
          ═══════════════════════════════════════════════════════════════ */}
      <div className="panels-row-3">
        {/* Panel izquierdo: Top 5 platos */}
        <Panel title="Top 5 Platos Más Pedidos" icon="🏆" subtitle="Hoy">
          {topDishes.map((dish) => (
            <div key={dish.rank} className="panel-list-item">
              <div className="panel-list-item-left">
                <div className={`panel-list-item-rank ${rankClass(dish.rank)}`}>
                  {dish.rank}
                </div>
                <div>
                  <div className="panel-list-item-name">{dish.name}</div>
                  <div className="panel-list-item-detail">{dish.category}</div>
                </div>
              </div>
              <div className="progress-bar-container">
                <div
                  className="progress-bar-fill"
                  style={{ width: `${dish.pct}%` }}
                />
              </div>
              <div className="panel-list-item-value">{dish.orders}</div>
            </div>
          ))}
        </Panel>

        {/* Panel derecho: Anillo de ocupación */}
        <Panel title="Ocupación de Mesas" icon="🪑" subtitle="Tiempo real">
          <div className="occupancy-ring">
            <div className="occupancy-ring-visual">
              <svg className="occupancy-ring-svg" viewBox="0 0 140 140">
                <circle className="occupancy-ring-bg" cx="70" cy="70" r="65" />
                <circle
                  className="occupancy-ring-fill"
                  cx="70" cy="70" r="65"
                  style={{ strokeDashoffset: strokeOffset }}
                />
              </svg>
              <div className="occupancy-ring-text">
                <span className="occupancy-ring-value">{occupancyPct}%</span>
                <span className="occupancy-ring-label">ocupado</span>
              </div>
            </div>
            <div className="occupancy-details">
              <div className="occupancy-detail">
                <div className="occupancy-detail-value">41</div>
                <div className="occupancy-detail-label">Mesas ocupadas</div>
              </div>
              <div className="occupancy-detail">
                <div className="occupancy-detail-value">9</div>
                <div className="occupancy-detail-label">Mesas libres</div>
              </div>
              <div className="occupancy-detail">
                <div className="occupancy-detail-value">50</div>
                <div className="occupancy-detail-label">Total</div>
              </div>
            </div>
          </div>
        </Panel>
      </div>

      {/* ═══════════════════════════════════════════════════════════════
          SECCIÓN 3: Alertas alérgenos + Actividad horaria
          ═══════════════════════════════════════════════════════════════ */}
      <div className="panels-row">
        {/* Panel izquierdo: Alertas de alérgenos */}
        <Panel title="Alertas de Alérgenos" icon="⚠️" subtitle="Últimas 24h">
          <table className="panel-table">
            <thead>
              <tr>
                <th>Hora</th>
                <th>Comensal</th>
                <th>Alérgeno</th>
                <th>Plato</th>
                <th>Estado</th>
              </tr>
            </thead>
            <tbody>
              {allergenAlerts.map((alert, i) => (
                <tr key={i}>
                  <td style={{ fontVariantNumeric: 'tabular-nums' }}>{alert.time}</td>
                  <td>{alert.comensal}</td>
                  <td>
                    <span className={`badge ${alert.severity === 'alta' ? 'badge-danger' : 'badge-warning'}`}>
                      {alert.allergen}
                    </span>
                  </td>
                  <td style={{ color: 'var(--text-secondary)' }}>{alert.dish}</td>
                  <td>
                    <span className={`badge ${alert.resolved ? 'badge-success' : 'badge-danger'}`}>
                      {alert.resolved ? '✓ Resuelto' : '⚡ Activa'}
                    </span>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </Panel>

        {/* Panel derecho: Actividad por horas */}
        <Panel title="Actividad del Día" icon="📈" subtitle="Pedidos por hora">
          <div className="activity-bars">
            {hourlyActivity.map((value, i) => (
              <div
                key={i}
                className="activity-bar"
                style={{ height: `${value}%` }}
                title={`${8 + i}:00 — ${value} pedidos`}
              />
            ))}
          </div>
          <div style={{
            display: 'flex',
            justifyContent: 'space-between',
            marginTop: 'var(--space-sm)',
            fontSize: 'var(--font-size-xs)',
            color: 'var(--text-muted)'
          }}>
            <span>8:00</span>
            <span>12:00</span>
            <span>16:00</span>
            <span>20:00</span>
            <span>22:00</span>
          </div>
        </Panel>
      </div>
    </div>
  )
}

export default OverviewPage
