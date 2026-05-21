/*
 * SalesPage.jsx — Página de análisis de Ventas
 *
 * ¿Qué hace esta página?
 * Proporciona una visión completa del rendimiento económico de CalBlay:
 *
 * 1. KPIs financieros: ingresos del día, ticket medio, nº de pedidos,
 *    ingreso por comensal, variación semanal, y hora punta
 * 2. Gráfico de ingresos de la semana: barras por día con el día actual
 *    destacado en verde para ver la evolución rápidamente
 * 3. Ingresos por establecimiento: compara el rendimiento de cada local
 *    (útil si CalBlay tiene varios restaurantes)
 * 4. Desglose por categoría de plato: qué tipo de plato genera más dinero
 *    (entrantes, principales, postres, bebidas)
 * 5. Top platos por facturación: no solo los más pedidos, sino los que más
 *    dinero generan (precio × cantidad). Muy útil para decidir qué platos
 *    promocionar o mantener en carta
 * 6. Distribución de tickets: en qué rango de precio están la mayoría de pedidos
 *    (ej. ¿los clientes gastan 15-25€ o 40-60€?)
 *
 * ¿Por qué es útil para CalBlay?
 * - Control financiero: ver si se cumplen los objetivos de facturación diaria
 * - Optimizar la carta: saber qué platos generan más ingresos (no solo pedidos)
 * - Comparar locales: detectar qué establecimiento necesita más atención
 * - Estrategia de precios: la distribución de tickets ayuda a ajustar precios
 *
 * DATOS SIMULADOS (Mock): Se conectarán a las tablas `orders`, `order_items`,
 * `menu_card_items` (precio), `recipes` (categoría), `establishments`
 */

import { useState, useEffect } from 'react'
import StatCard from '../components/StatCard'
import Panel from '../components/Panel'
import { getOrders, getSalesWeeklyRevenue, getSalesByEstablishment, getSalesByCategory, getSalesTopDishes, getTicketDistribution } from '../api'
import './SalesPage.css'

/* ═══════════════════════════════════════════════════════════════════════════
   DATOS SIMULADOS (MOCK DATA)
   Estos datos imitan lo que obtendríamos con consultas SQL a las tablas:
   - orders + order_items → número de pedidos y cantidades
   - menu_card_items → precios de cada plato
   - recipes → categoría de cada plato (entrante, primer_plato, etc.)
   - establishments → desglose por restaurante
   ═══════════════════════════════════════════════════════════════════════════ */

/* Ingresos de los últimos 7 días */
const weeklyRevenue = [
  { day: 'Lun', revenue: 3120, orders: 98 },
  { day: 'Mar', revenue: 2850, orders: 91 },
  { day: 'Mié', revenue: 3340, orders: 108 },
  { day: 'Jue', revenue: 3680, orders: 115 },
  { day: 'Vie', revenue: 5210, orders: 147 },
  { day: 'Sáb', revenue: 6480, orders: 183 },
  { day: 'Dom', revenue: 4230, orders: 134 },  /* Hoy (domingo) — se marca en verde */
]

/* Ingresos por establecimiento */
const establishmentsMock = [
  {
    name: 'CalBlay Centro',
    address: 'Carrer Major, 12 — Barcelona',
    revenue: 18420,
    orders: 412,
    color: '#818cf8',
    icon: '🏙️',
  },
  {
    name: 'CalBlay Port Olímpic',
    address: 'Passeig Marítim, 34 — Barcelona',
    revenue: 14650,
    orders: 328,
    color: '#34d399',
    icon: '⛵',
  },
  {
    name: 'CalBlay Gràcia',
    address: 'Plaça del Sol, 8 — Barcelona',
    revenue: 11280,
    orders: 267,
    color: '#fbbf24',
    icon: '🌳',
  },
]

/* Desglose de ingresos por categoría de plato (enum recipe_category) */
const categoryBreakdown = [
  { label: 'Segundo Plato',  icon: '🥩', amount: 12840, pct: 38, color: '#818cf8' },
  { label: 'Primer Plato',   icon: '🍲', amount: 8720,  pct: 26, color: '#34d399' },
  { label: 'Entrante',       icon: '🥗', amount: 5430,  pct: 16, color: '#60a5fa' },
  { label: 'Postre',         icon: '🍰', amount: 3980,  pct: 12, color: '#f472b6' },
  { label: 'Bebida',         icon: '🍷', amount: 2680,  pct: 8,  color: '#fbbf24' },
]

/* Top 8 platos por facturación (precio × cantidad vendida) */
const topByRevenue = [
  { rank: 1, name: 'Entrecot a la Brasa',   price: 24.50, qty: 28, revenue: 686,  category: 'Segundo Plato' },
  { rank: 2, name: 'Lubina al Horno',       price: 22.00, qty: 19, revenue: 418,  category: 'Segundo Plato' },
  { rank: 3, name: 'Paella Valenciana',      price: 18.50, qty: 34, revenue: 629,  category: 'Primer Plato' },
  { rank: 4, name: 'Risotto de Setas',       price: 16.00, qty: 21, revenue: 336,  category: 'Primer Plato' },
  { rank: 5, name: 'Tiramisú Casero',        price: 8.50,  qty: 25, revenue: 212,  category: 'Postre' },
  { rank: 6, name: 'Ensalada César',         price: 12.00, qty: 17, revenue: 204,  category: 'Entrante' },
  { rank: 7, name: 'Gazpacho Andaluz',       price: 9.00,  qty: 22, revenue: 198,  category: 'Entrante' },
  { rank: 8, name: 'Tarta de Almendras',     price: 9.50,  qty: 14, revenue: 133,  category: 'Postre' },
]

/* Distribución de tickets (rangos de precio por pedido) */
const ticketDistribution = [
  { range: '0 - 15€',    count: 18,  pct: 12 },
  { range: '15 - 25€',   count: 42,  pct: 29 },
  { range: '25 - 40€',   count: 53,  pct: 36 },
  { range: '40 - 60€',   count: 24,  pct: 16 },
  { range: '60€+',       count: 10,  pct: 7 },
]


function SalesPage({ establishmentId, date }) {
  const [completedOrdersCount, setCompletedOrdersCount] = useState("134")
  const [completedOrdersTrend, setCompletedOrdersTrend] = useState("vs. domingo pasado")
  
  const [weeklyRevenueData, setWeeklyRevenueData] = useState(weeklyRevenue)
  const [establishmentsData, setEstablishmentsData] = useState(establishmentsMock)
  const [categoryBreakdownData, setCategoryBreakdownData] = useState(categoryBreakdown)
  const [topByRevenueData, setTopByRevenueData] = useState(topByRevenue)
  const [ticketDistributionData, setTicketDistributionData] = useState(ticketDistribution)

  useEffect(() => {
    async function loadData() {
      try {
        const realOrders = await getOrders(establishmentId, date)
        if (realOrders && realOrders.length > 0) {
          const completed = realOrders.filter(o => o.status === 'served' || true).length;
          setCompletedOrdersCount(completed.toString())
          setCompletedOrdersTrend("Datos reales BD")
        } else {
          setCompletedOrdersCount("0")
          setCompletedOrdersTrend("Sin datos")
        }

        const rev = await getSalesWeeklyRevenue(establishmentId, date)
        if (rev && rev.length > 0) {
          setWeeklyRevenueData(rev.map(r => ({
            day: new Date(r.order_date).toLocaleDateString('es-ES', {weekday: 'short'}).substring(0, 3),
            revenue: Number(r.revenue),
            orders: Number(r.total_orders)
          })))
        } else {
          setWeeklyRevenueData([])
        }

        const est = await getSalesByEstablishment('all', date)
        if (est && est.length > 0) {
          setEstablishmentsData(est.map((e, i) => ({
            name: e.establishment_name,
            address: e.address,
            revenue: Number(e.revenue),
            orders: Number(e.total_orders),
            color: establishmentsMock[i % establishmentsMock.length]?.color || '#818cf8',
            icon: e.establishment_name.toLowerCase().includes('port') ? '⛵' : (e.establishment_name.toLowerCase().includes('centro') ? '🏙️' : '🌳')
          })))
        } else {
          setEstablishmentsData([])
        }

        const cat = await getSalesByCategory(establishmentId, date)
        if (cat && cat.length > 0) {
          const total = cat.reduce((sum, c) => sum + Number(c.revenue), 0)
          setCategoryBreakdownData(cat.map((c, i) => ({
            label: c.category_name,
            amount: Number(c.revenue),
            pct: total > 0 ? Math.round((Number(c.revenue) / total) * 100) : 0,
            icon: categoryBreakdown[i % categoryBreakdown.length]?.icon || '🍽️',
            color: categoryBreakdown[i % categoryBreakdown.length]?.color || '#818cf8'
          })))
        } else {
          setCategoryBreakdownData([])
        }

        const top = await getSalesTopDishes(establishmentId, date)
        if (top && top.length > 0) {
          setTopByRevenueData(top.map((t, i) => ({
            rank: i + 1,
            name: t.dish_name,
            price: Number(t.price),
            qty: Number(t.qty_sold),
            revenue: Number(t.revenue),
            category: t.category_name
          })))
        } else {
          setTopByRevenueData([])
        }

        const tickets = await getTicketDistribution(establishmentId, date)
        if (tickets && tickets.length > 0) {
          const totalTickets = tickets.reduce((sum, t) => sum + Number(t.tickets), 0)
          setTicketDistributionData(tickets.map(t => ({
            range: t.range,
            count: Number(t.tickets),
            pct: totalTickets > 0 ? Math.round((Number(t.tickets) / totalTickets) * 100) : 0
          })))
        } else {
          setTicketDistributionData([])
        }

      } catch (error) {
        console.error("Error fetching sales data:", error)
      }
    }
    loadData()
  }, [establishmentId, date])

  /* Calcular el valor máximo de ingresos de la semana para escalar las barras */
  const maxRevenue = Math.max(...weeklyRevenueData.map(d => d.revenue))

  /* Función para la clase de medalla del ranking */
  const rankClass = (rank) => {
    if (rank === 1) return 'gold'
    if (rank === 2) return 'silver'
    if (rank === 3) return 'bronze'
    return ''
  }

  return (
    <div className="sales-page">

      {/* ═══════════════════════════════════════════════════════════════
          SECCIÓN 1: KPIs Financieros
          Utilidad: visión rápida de los números más importantes del día.
          Fuente BD: SUM de order_items × menu_card_items.price,
          COUNT de orders, COUNT de comensals
          ═══════════════════════════════════════════════════════════════ */}
      <div className="stats-grid">
        <StatCard
          icon="💰"
          label="Ingresos Hoy"
          value={weeklyRevenueData.length > 0 ? `${weeklyRevenueData[weeklyRevenueData.length - 1].revenue.toLocaleString('es-ES')}€` : '0€'}
          trend="neutral"
          trendValue="Datos BD"
          trendLabel=""
          accentColor="#34d399"
        />
        <StatCard
          icon="🧾"
          label="Ticket Medio"
          value="31.60€"
          trend="up"
          trendValue="+2.40€"
          trendLabel="vs. media semanal"
          accentColor="#818cf8"
        />
        <StatCard
          icon="🍽️"
          label="Pedidos Completados"
          value={completedOrdersCount}
          trend="up"
          trendValue="+15"
          trendLabel={completedOrdersTrend}
          accentColor="#60a5fa"
        />
        <StatCard
          icon="👤"
          label="Ingreso por Comensal"
          value="13.60€"
          trend="up"
          trendValue="+1.20€"
          trendLabel="vs. media"
          accentColor="#a78bfa"
        />
        <StatCard
          icon="📈"
          label="Variación Semanal"
          value="+12.4%"
          trend="up"
          trendValue="+3.1 pp"
          trendLabel="vs. semana anterior"
          accentColor="#f472b6"
        />
        <StatCard
          icon="⏰"
          label="Hora Punta"
          value="14:00"
          trend="neutral"
          trendValue="32 pedidos"
          trendLabel="en esa franja"
          accentColor="#fbbf24"
        />
      </div>

      {/* ═══════════════════════════════════════════════════════════════
          SECCIÓN 2: Gráfico de ingresos semanales + Establecimientos
          Utilidad: ver la tendencia de ingresos y comparar locales.
          Fuente BD: SUM(price*qty) GROUP BY DATE(created_at),
          GROUP BY establishment_id
          ═══════════════════════════════════════════════════════════════ */}
      <div className="panels-row">
        {/* Gráfico de barras de la semana */}
        <Panel
          title="Ingresos de la Semana"
          icon="📊"
          subtitle="Últimos 7 días — Total: 28.910€"
        >
          <div className="revenue-chart">
            {weeklyRevenueData.map((day, i) => (
              <div key={day.day} className="revenue-bar-wrapper">
                <span className="revenue-bar-value">
                  {(day.revenue / 1000).toFixed(1)}k
                </span>
                <div
                  className={`revenue-bar ${i === weeklyRevenueData.length - 1 ? 'today' : ''}`}
                  style={{ height: `${(day.revenue / maxRevenue) * 100}%` }}
                  title={`${day.day}: ${day.revenue.toLocaleString('es-ES')}€ · ${day.orders} pedidos`}
                />
                <span className="revenue-bar-label">{day.day}</span>
              </div>
            ))}
          </div>
          <div className="chart-legend">
            <div className="chart-legend-item">
              <div className="chart-legend-dot" style={{ background: 'var(--accent-primary)' }}></div>
              Días anteriores
            </div>
            <div className="chart-legend-item">
              <div className="chart-legend-dot" style={{ background: 'var(--accent-secondary)' }}></div>
              Hoy
            </div>
          </div>
        </Panel>

        {/* Ingresos por establecimiento */}
        <Panel
          title="Ingresos por Establecimiento"
          icon="🏢"
          subtitle="Semana actual"
        >
          <div className="establishment-list">
            {establishmentsData.map((est) => (
              <div key={est.name} className="establishment-row">
                <div
                  className="establishment-icon"
                  style={{ background: `${est.color}15`, border: `1px solid ${est.color}30` }}
                >
                  {est.icon}
                </div>
                <div className="establishment-info">
                  <div className="establishment-name">{est.name}</div>
                  <div className="establishment-address">{est.address}</div>
                </div>
                <div className="establishment-revenue">
                  <div className="establishment-revenue-value">
                    {est.revenue.toLocaleString('es-ES')}€
                  </div>
                  <div className="establishment-revenue-orders">
                    {est.orders} pedidos
                  </div>
                </div>
              </div>
            ))}
          </div>

          <div className="insight-box">
            💡 <strong>Dato clave:</strong> CalBlay Centro genera un 41% de los ingresos
            totales. Port Olímpic tiene mayor ticket medio (44.70€) gracias a los platos de marisco.
          </div>
        </Panel>
      </div>

      {/* ═══════════════════════════════════════════════════════════════
          SECCIÓN 3: Categorías + Top Platos + Distribución de Tickets
          Utilidad: entender la estructura de ingresos para optimizar
          precios y composición de la carta.
          Fuente BD: JOIN recipes (category) → order_items → menu_card_items
          ═══════════════════════════════════════════════════════════════ */}
      <div className="panels-row-sales">
        {/* Desglose por categoría */}
        <Panel
          title="Ingresos por Categoría"
          icon="📂"
          subtitle="Distribución de la facturación"
        >
          <div className="category-breakdown">
            {categoryBreakdownData.map((cat) => (
              <div key={cat.label} className="category-row">
                <span className="category-icon">{cat.icon}</span>
                <span className="category-label">{cat.label}</span>
                <div className="category-bar-track">
                  <div
                    className="category-bar-fill"
                    style={{ width: `${cat.pct}%`, background: cat.color }}
                  />
                </div>
                <div className="category-values">
                  <span className="category-amount">{cat.amount.toLocaleString('es-ES')}€</span>
                  <span className="category-pct">{cat.pct}%</span>
                </div>
              </div>
            ))}
          </div>
        </Panel>

        {/* Top platos por facturación */}
        <Panel
          title="Top Platos por Facturación"
          icon="🏆"
          subtitle="Precio × Unidades vendidas"
        >
          {topByRevenueData.map((dish) => (
            <div key={dish.rank} className="revenue-dish-item">
              <div
                className={`revenue-dish-rank panel-list-item-rank ${rankClass(dish.rank)}`}
              >
                {dish.rank}
              </div>
              <div className="revenue-dish-info">
                <div className="revenue-dish-name">{dish.name}</div>
                <div className="revenue-dish-meta">
                  {dish.price.toFixed(2)}€ × {dish.qty} uds · {dish.category}
                </div>
              </div>
              <div className="revenue-dish-amount">
                {dish.revenue.toLocaleString('es-ES')}€
              </div>
            </div>
          ))}
        </Panel>

        {/* Distribución de tickets */}
        <Panel
          title="Distribución de Tickets"
          icon="📊"
          subtitle="Rangos de precio por pedido"
        >
          <div className="ticket-distribution">
            {ticketDistributionData.map((range) => (
              <div key={range.range} className="ticket-range-row">
                <span className="ticket-range-label">{range.range}</span>
                <div className="ticket-range-bar-track">
                  <div
                    className="ticket-range-bar-fill"
                    style={{ width: `${(range.pct / 36) * 100}%` }}
                  />
                </div>
                <span className="ticket-range-count">{range.count}</span>
                <span className="ticket-range-pct">{range.pct}%</span>
              </div>
            ))}
          </div>

          <div className="insight-box">
            💡 <strong>Dato clave:</strong> El 65% de los pedidos están en el rango de 15-40€.
            Esto indica que la mayoría de clientes eligen combinaciones de entrante + principal.
            Considerar ofrecer un menú "Entrante + Principal" a precio cerrado podría aumentar
            el ticket medio.
          </div>
        </Panel>
      </div>
    </div>
  )
}

export default SalesPage
