/*
 * Sidebar.jsx — Menú lateral de navegación del Dashboard
 *
 * ¿Qué hace este componente?
 * Muestra el menú lateral fijo con:
 * - La marca "CalBlay" arriba
 * - Enlaces de navegación organizados por secciones
 * - La información del usuario conectado abajo
 *
 * ¿Cómo funciona?
 * - Recibe "activePage" (la página actual) y "onNavigate" (función para cambiar de página)
 * - Marca el enlace activo con un color diferente
 * - Los emojis actúan como iconos (más adelante se pueden cambiar por iconos SVG)
 */

import './Sidebar.css'

function Sidebar({ activePage, onNavigate }) {
  /* Definimos los elementos del menú en un array de objetos.
     Cada objeto tiene: id (identificador), icon (emoji), label (texto visible),
     y opcionalmente badge (un número de notificación). */
  const menuItems = [
    { section: 'General' },
    { id: 'overview', icon: '📊', label: 'Vista General' },
    { id: 'sales', icon: '💰', label: 'Ventas' },
    { id: 'orders', icon: '🍽️', label: 'Pedidos' },

    { section: 'Operaciones' },
    { id: 'tables', icon: '🪑', label: 'Ocupación' },
    { id: 'staff', icon: '👥', label: 'Personal' },

    { section: 'Salud y Clientes' },
    { id: 'allergens', icon: '⚠️', label: 'Alérgenos' },
  ]


  return (
    <aside className="sidebar">
      {/* ── Marca / Logo ── */}
      <div className="sidebar-brand">
        <div className="sidebar-brand-icon">CB</div>
        <div className="sidebar-brand-text">
          <span className="sidebar-brand-name">CalBlay</span>
          <span className="sidebar-brand-label">Analytics</span>
        </div>
      </div>

      {/* ── Enlaces de navegación ── */}
      <nav className="sidebar-nav">
        {menuItems.map((item, index) => {
          /* Si el elemento tiene "section", renderiza un título de sección */
          if (item.section) {
            return (
              <div key={`section-${index}`} className="sidebar-section-title">
                {item.section}
              </div>
            )
          }

          /* Si no, renderiza un enlace normal */
          return (
            <div
              key={item.id}
              className={`sidebar-link ${activePage === item.id ? 'active' : ''}`}
              onClick={() => onNavigate(item.id)}
            >
              <span className="sidebar-link-icon">{item.icon}</span>
              <span>{item.label}</span>
              {item.badge && (
                <span className="sidebar-link-badge">{item.badge}</span>
              )}
            </div>
          )
        })}
      </nav>

      {/* ── Usuario conectado ── */}
      <div className="sidebar-footer">
        <div className="sidebar-user">
          <div className="sidebar-avatar">HF</div>
          <div className="sidebar-user-info">
            <span className="sidebar-user-name">Hugo Fernández</span>
            <span className="sidebar-user-role">Administrador</span>
          </div>
        </div>
      </div>
    </aside>
  )
}

export default Sidebar
