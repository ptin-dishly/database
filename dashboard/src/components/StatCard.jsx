/*
 * StatCard.jsx — Tarjeta de estadística individual (KPI Card)
 *
 * ¿Qué hace este componente?
 * Muestra UNA tarjeta con un número destacado grande (KPI = Key Performance Indicator).
 * Por ejemplo: "Pedidos Hoy: 147", "Ingresos: 4.230€", "Ocupación: 82%"
 *
 * ¿Qué recibe como datos (props)?
 * - icon:   Emoji o icono que representa la métrica
 * - label:  Texto descriptivo (ej. "Pedidos Hoy")
 * - value:  El número grande destacado (ej. "147")
 * - trend:  Flecha de tendencia: "up" (sube), "down" (baja), "neutral"
 * - trendValue: El porcentaje de cambio (ej. "+12.5%")
 * - trendLabel: Texto del periodo (ej. "vs. ayer")
 * - accentColor: Color CSS personalizado para el icono
 */

import './StatCard.css'

function StatCard({ icon, label, value, trend = 'neutral', trendValue, trendLabel, accentColor }) {
  /* Elegimos la flecha según la tendencia */
  const trendArrow = trend === 'up' ? '↑' : trend === 'down' ? '↓' : '→'

  return (
    <div
      className="stat-card"
      style={accentColor ? { '--card-accent': accentColor, '--card-accent-bg': `${accentColor}15` } : {}}
    >
      {/* Cabecera: etiqueta + icono */}
      <div className="stat-card-header">
        <span className="stat-card-label">{label}</span>
        <div className="stat-card-icon">{icon}</div>
      </div>

      {/* Valor grande */}
      <div className="stat-card-value">{value}</div>

      {/* Tendencia */}
      {trendValue && (
        <div>
          <span className={`stat-card-trend ${trend}`}>
            {trendArrow} {trendValue}
          </span>
          {trendLabel && (
            <span className="stat-card-trend-label">{trendLabel}</span>
          )}
        </div>
      )}
    </div>
  )
}

export default StatCard
