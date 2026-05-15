/*
 * Panel.jsx — Contenedor tipo tarjeta para secciones de contenido
 *
 * ¿Qué hace este componente?
 * Es un "marco" visual reutilizable que envuelve cualquier contenido
 * (gráficas, tablas, listas...) dándole el estilo elegante de cristal.
 *
 * ¿Qué recibe?
 * - title:    Título del panel (ej. "Top 5 Platos Más Pedidos")
 * - subtitle: Descripción breve opcional
 * - icon:     Emoji del título
 * - children: El contenido que va dentro (React inserta automáticamente
 *             lo que pongas entre <Panel> y </Panel>)
 */

import './Panel.css'

function Panel({ title, subtitle, icon, children, actions, style }) {
  return (
    <div className="panel" style={style}>
      {/* Cabecera del panel */}
      {title && (
        <div className="panel-header">
          <div>
            <div className="panel-title">
              {icon && <span>{icon}</span>}
              {title}
            </div>
            {subtitle && <div className="panel-subtitle">{subtitle}</div>}
          </div>
          {actions && <div className="panel-actions">{actions}</div>}
        </div>
      )}

      {/* Contenido del panel (lo que se ponga entre <Panel>...</Panel>) */}
      {children}
    </div>
  )
}

export default Panel
