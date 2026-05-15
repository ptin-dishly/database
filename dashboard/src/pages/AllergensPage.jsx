/*
 * AllergensPage.jsx — Página de Gestión y Análisis de Alérgenos
 *
 * ¿Qué hace esta página?
 * Proporciona una visión completa de la gestión de alérgenos en el restaurante:
 *
 * 1. KPIs rápidos: alertas activas, total de alérgenos gestionados, platos "seguros",
 *    tasa de resolución de alertas
 * 2. Los 14 alérgenos de la UE: muestra la frecuencia con la que cada alérgeno
 *    aparece entre los comensales registrados (útil para saber qué alternativas ofrecer)
 * 3. Mapa de calor (Heatmap): cruza los platos de la carta con los alérgenos.
 *    De un vistazo, la cocina puede saber qué platos contienen qué alérgenos.
 * 4. Distribución de presencia: cuántos ingredientes "contienen", "pueden contener"
 *    o tienen "trazas" de cada alérgeno
 * 5. Alternativas sugeridas: para cada plato conflictivo, muestra una alternativa
 *    sin ese alérgeno (muy útil para camareros)
 * 6. Historial de alertas recientes
 *
 * ¿Por qué es útil para CalBlay?
 * - Cumplimiento legal: La normativa europea obliga a informar sobre los 14 alérgenos
 * - Prevención de riesgos: Identifica platos problemáticos antes de que haya incidentes
 * - Mejora del servicio: Los camareros pueden anticiparse a las necesidades del cliente
 * - Optimización de la carta: Saber qué alérgenos son más frecuentes ayuda a diseñar
 *   menús más inclusivos
 *
 * DATOS SIMULADOS (Mock): En la siguiente fase se conectarán a la base de datos real.
 */

import StatCard from '../components/StatCard'
import Panel from '../components/Panel'
import './AllergensPage.css'

/* ═══════════════════════════════════════════════════════════════════════════
   DATOS SIMULADOS (MOCK DATA)
   Estos datos imitan lo que vendría de las tablas:
   - allergens (los 14 alérgenos UE)
   - comensal_allergens (qué alergias tiene cada comensal)
   - recipe_allergens (qué alérgenos tiene cada receta)
   - allergen_alerts (alertas generadas)
   - ingredient_allergens (presencia: contains, may_contain, traces)
   ═══════════════════════════════════════════════════════════════════════════ */

/* Los 14 alérgenos obligatorios de la UE según el Reglamento (UE) 1169/2011 */
const eu14Allergens = [
  { euNumber: 1,  code: 'gluten',      nameEs: 'Gluten',           icon: '🌾', comensals: 47, pct: 100, severity: 'high' },
  { euNumber: 2,  code: 'crustaceans', nameEs: 'Crustáceos',       icon: '🦐', comensals: 12, pct: 26,  severity: 'low' },
  { euNumber: 3,  code: 'eggs',        nameEs: 'Huevos',           icon: '🥚', comensals: 38, pct: 81,  severity: 'high' },
  { euNumber: 4,  code: 'fish',        nameEs: 'Pescado',          icon: '🐟', comensals: 15, pct: 32,  severity: 'medium' },
  { euNumber: 5,  code: 'peanuts',     nameEs: 'Cacahuetes',       icon: '🥜', comensals: 29, pct: 62,  severity: 'high' },
  { euNumber: 6,  code: 'soy',         nameEs: 'Soja',             icon: '🫘', comensals: 18, pct: 38,  severity: 'medium' },
  { euNumber: 7,  code: 'milk',        nameEs: 'Lácteos',          icon: '🥛', comensals: 42, pct: 89,  severity: 'high' },
  { euNumber: 8,  code: 'nuts',        nameEs: 'Frutos de cáscara',icon: '🌰', comensals: 33, pct: 70,  severity: 'high' },
  { euNumber: 9,  code: 'celery',      nameEs: 'Apio',             icon: '🥬', comensals: 5,  pct: 11,  severity: 'low' },
  { euNumber: 10, code: 'mustard',     nameEs: 'Mostaza',          icon: '🟡', comensals: 8,  pct: 17,  severity: 'low' },
  { euNumber: 11, code: 'sesame',      nameEs: 'Sésamo',           icon: '⚪', comensals: 11, pct: 23,  severity: 'low' },
  { euNumber: 12, code: 'sulphites',   nameEs: 'Sulfitos',         icon: '🍷', comensals: 22, pct: 47,  severity: 'medium' },
  { euNumber: 13, code: 'lupin',       nameEs: 'Altramuces',       icon: '🌿', comensals: 3,  pct: 6,   severity: 'low' },
  { euNumber: 14, code: 'molluscs',    nameEs: 'Moluscos',         icon: '🦪', comensals: 9,  pct: 19,  severity: 'low' },
]

/* Mapa de calor: cruce platos × alérgenos (datos de recipe_allergens + ingredient_allergens) */
const heatmapData = [
  { dish: 'Paella Valenciana',   allergens: { gluten: '', crustaceans: 'C', eggs: '', fish: 'C', peanuts: '', soy: '', milk: '', nuts: '', celery: '', mustard: '', sesame: '', sulphites: 'T', lupin: '', molluscs: 'C' } },
  { dish: 'Entrecot a la Brasa', allergens: { gluten: '', crustaceans: '', eggs: '', fish: '', peanuts: '', soy: 'T', milk: 'C', nuts: '', celery: '', mustard: 'C', sesame: '', sulphites: 'C', lupin: '', molluscs: '' } },
  { dish: 'Tiramisú Casero',     allergens: { gluten: 'C', crustaceans: '', eggs: 'C', fish: '', peanuts: '', soy: '', milk: 'C', nuts: 'T', celery: '', mustard: '', sesame: '', sulphites: '', lupin: '', molluscs: '' } },
  { dish: 'Gazpacho Andaluz',    allergens: { gluten: 'C', crustaceans: '', eggs: '', fish: '', peanuts: '', soy: '', milk: '', nuts: '', celery: 'C', mustard: '', sesame: '', sulphites: 'C', lupin: '', molluscs: '' } },
  { dish: 'Lubina al Horno',     allergens: { gluten: '', crustaceans: '', eggs: '', fish: 'C', peanuts: '', soy: '', milk: 'C', nuts: '', celery: '', mustard: '', sesame: '', sulphites: 'C', lupin: '', molluscs: '' } },
  { dish: 'Ensalada César',      allergens: { gluten: 'C', crustaceans: '', eggs: 'C', fish: 'C', peanuts: '', soy: 'T', milk: 'C', nuts: '', celery: '', mustard: 'C', sesame: 'T', sulphites: '', lupin: '', molluscs: '' } },
  { dish: 'Risotto de Setas',    allergens: { gluten: '', crustaceans: '', eggs: '', fish: '', peanuts: '', soy: '', milk: 'C', nuts: '', celery: 'C', mustard: '', sesame: '', sulphites: 'C', lupin: '', molluscs: '' } },
  { dish: 'Tarta de Almendras',  allergens: { gluten: 'C', crustaceans: '', eggs: 'C', fish: '', peanuts: 'T', soy: '', milk: 'C', nuts: 'C', celery: '', mustard: '', sesame: '', sulphites: '', lupin: '', molluscs: '' } },
]

/* Distribución de presencia de alérgenos en los ingredientes de la carta */
const presenceDistribution = [
  { label: 'Contiene', value: 68, color: 'var(--accent-danger)' },
  { label: 'Puede contener', value: 23, color: 'var(--accent-warning)' },
  { label: 'Trazas', value: 15, color: 'var(--accent-info)' },
]

/* Alternativas sugeridas: platos que causan más alertas y su alternativa sin el alérgeno */
const alternatives = [
  {
    original: 'Tiramisú Casero',
    originalAllergens: ['Gluten', 'Huevos', 'Lácteos'],
    replacement: 'Sorbete de Mango',
    reason: 'Sin gluten, sin huevos, sin lácteos — apto para 85% de intolerancias comunes',
  },
  {
    original: 'Ensalada César',
    originalAllergens: ['Gluten', 'Huevos', 'Pescado', 'Lácteos'],
    replacement: 'Ensalada Mediterránea',
    reason: 'Aliño de aceite y limón — elimina anchoas, parmesano y croutons',
  },
  {
    original: 'Tarta de Almendras',
    originalAllergens: ['Gluten', 'Huevos', 'Frutos secos'],
    replacement: 'Crema Catalana sin Gluten',
    reason: 'Elaborada con maicena — sin frutos secos ni gluten',
  },
  {
    original: 'Paella Valenciana',
    originalAllergens: ['Crustáceos', 'Moluscos'],
    replacement: 'Paella de Verduras',
    reason: 'Misma receta base sin marisco — apta para alérgicos a crustáceos y moluscos',
  },
]

/* Historial de alertas recientes con más detalle */
const recentAlerts = [
  { id: 1, time: '14:23', date: 'Hoy',       comensal: 'María G.',   allergen: 'Gluten',        dish: 'Pan de Hogaza',     table: 'Mesa 7',  severity: 'alta',  resolved: false, waiter: 'Carlos M.' },
  { id: 2, time: '13:45', date: 'Hoy',       comensal: 'Carlos P.',  allergen: 'Lactosa',       dish: 'Salsa Bechamel',    table: 'Mesa 3',  severity: 'media', resolved: true,  waiter: 'Ana L.' },
  { id: 3, time: '12:10', date: 'Hoy',       comensal: 'Ana R.',     allergen: 'Frutos Secos',  dish: 'Tarta de Almendras',table: 'Mesa 12', severity: 'alta',  resolved: true,  waiter: 'Pedro S.' },
  { id: 4, time: '21:30', date: 'Ayer',      comensal: 'Luis M.',    allergen: 'Huevos',        dish: 'Tiramisú Casero',   table: 'Mesa 5',  severity: 'media', resolved: true,  waiter: 'Carlos M.' },
  { id: 5, time: '20:15', date: 'Ayer',      comensal: 'Elena V.',   allergen: 'Crustáceos',    dish: 'Paella Valenciana', table: 'Mesa 9',  severity: 'alta',  resolved: true,  waiter: 'Ana L.' },
  { id: 6, time: '14:50', date: '07/05',     comensal: 'Jordi B.',   allergen: 'Sulfitos',      dish: 'Vino Tinto Reserva',table: 'Mesa 2',  severity: 'baja',  resolved: true,  waiter: 'Pedro S.' },
]


function AllergensPage() {
  /* Códigos abreviados para las cabeceras del heatmap */
  const allergenCodes = ['GLU', 'CRU', 'HUE', 'PES', 'CAC', 'SOJ', 'LAC', 'FSC', 'API', 'MOS', 'SES', 'SUL', 'ALT', 'MOL']
  const allergenKeys = ['gluten', 'crustaceans', 'eggs', 'fish', 'peanuts', 'soy', 'milk', 'nuts', 'celery', 'mustard', 'sesame', 'sulphites', 'lupin', 'molluscs']

  /* Función que devuelve la clase CSS según el valor de la celda del heatmap */
  const getCellClass = (value) => {
    if (value === 'C') return 'heatmap-contains'
    if (value === 'T') return 'heatmap-traces'
    if (value === '✓') return 'heatmap-free'
    return 'heatmap-empty'
  }

  /* Función que devuelve el texto del tooltip según el valor */
  const getCellTitle = (value, dish, allergen) => {
    if (value === 'C') return `${dish}: CONTIENE ${allergen}`
    if (value === 'T') return `${dish}: TRAZAS de ${allergen}`
    return `${dish}: libre de ${allergen}`
  }

  return (
    <div className="allergens-page">

      {/* ═══════════════════════════════════════════════════════════════
          SECCIÓN 1: KPIs de Alérgenos
          Utilidad: Visión rápida del estado de la gestión de alérgenos
          ═══════════════════════════════════════════════════════════════ */}
      <div className="stats-grid">
        <StatCard
          icon="🚨"
          label="Alertas Activas"
          value="1"
          trend="down"
          trendValue="-80%"
          trendLabel="vs. semana pasada"
          accentColor="#f87171"
        />
        <StatCard
          icon="🛡️"
          label="Comensales con Alergias Registradas"
          value="89"
          trend="up"
          trendValue="+23"
          trendLabel="este mes"
          accentColor="#818cf8"
        />
        <StatCard
          icon="✅"
          label="Platos Libres de Top 4 Alérgenos"
          value="12"
          trend="neutral"
          trendValue="de 28 en carta"
          accentColor="#34d399"
        />
        <StatCard
          icon="⚡"
          label="Tasa de Resolución"
          value="97.2%"
          trend="up"
          trendValue="+2.1%"
          trendLabel="vs. mes anterior"
          accentColor="#fbbf24"
        />
      </div>

      {/* ═══════════════════════════════════════════════════════════════
          SECCIÓN 2: Los 14 Alérgenos UE — Frecuencia entre comensales
          Utilidad: Saber cuáles son los alérgenos más declarados por
          los clientes para priorizar alternativas en la carta
          ═══════════════════════════════════════════════════════════════ */}
      <div className="section-title-row">
        <span className="section-title-text">Los 14 Alérgenos de la UE — Frecuencia entre comensales</span>
      </div>

      <Panel
        title="Prevalencia de Alérgenos"
        icon="📊"
        subtitle="Basado en perfiles de comensales registrados — Reglamento (UE) 1169/2011"
      >
        <div className="allergen-grid">
          {eu14Allergens.map((a, i) => (
            <div
              key={a.code}
              className={`allergen-item severity-${a.severity}`}
              style={{ animationDelay: `${i * 0.04}s` }}
            >
              <span className="allergen-item-icon">{a.icon}</span>
              <span className="allergen-item-name">{a.nameEs}</span>
              <span className="allergen-item-eu">UE #{a.euNumber}</span>
              <span className="allergen-item-count">{a.comensals}</span>
              <span className="allergen-item-label">comensales</span>
              <div className="allergen-item-bar">
                <div
                  className="allergen-item-bar-fill"
                  style={{ width: `${a.pct}%` }}
                />
              </div>
            </div>
          ))}
        </div>
      </Panel>

      {/* ═══════════════════════════════════════════════════════════════
          SECCIÓN 3: Mapa de Calor (Heatmap) + Distribución de Presencia
          Utilidad para cocina: De un vistazo, ver qué platos contienen
          qué alérgenos. C = Contiene, T = Trazas, vacío = Libre
          ═══════════════════════════════════════════════════════════════ */}
      <div className="section-title-row">
        <span className="section-title-text">Análisis de la Carta</span>
      </div>

      <div className="panels-row-3">
        <Panel
          title="Mapa de Calor: Platos × Alérgenos"
          icon="🗺️"
          subtitle="C = Contiene · T = Trazas · Vacío = Libre"
        >
          <div className="heatmap-container">
            <table className="heatmap-table">
              <thead>
                <tr>
                  <th>Plato</th>
                  {allergenCodes.map((code, i) => (
                    <th key={code} title={eu14Allergens[i].nameEs}>{code}</th>
                  ))}
                </tr>
              </thead>
              <tbody>
                {heatmapData.map((row) => (
                  <tr key={row.dish}>
                    <td>{row.dish}</td>
                    {allergenKeys.map((key, i) => {
                      const value = row.allergens[key]
                      return (
                        <td key={key}>
                          <span
                            className={`heatmap-cell ${getCellClass(value || '')}`}
                            title={getCellTitle(value, row.dish, eu14Allergens[i].nameEs)}
                          >
                            {value || '·'}
                          </span>
                        </td>
                      )
                    })}
                  </tr>
                ))}
              </tbody>
            </table>
          </div>

          <div className="heatmap-legend">
            <div className="heatmap-legend-item">
              <div className="heatmap-legend-dot" style={{ background: 'rgba(248, 113, 113, 0.4)' }}></div>
              C = Contiene
            </div>
            <div className="heatmap-legend-item">
              <div className="heatmap-legend-dot" style={{ background: 'rgba(251, 191, 36, 0.4)' }}></div>
              T = Trazas
            </div>
            <div className="heatmap-legend-item">
              <div className="heatmap-legend-dot" style={{ background: 'rgba(255, 255, 255, 0.06)' }}></div>
              · = Libre
            </div>
          </div>
        </Panel>

        <Panel
          title="Distribución de Presencia"
          icon="📋"
          subtitle="En los ingredientes de la carta"
        >
          <div className="presence-distribution">
            {presenceDistribution.map((item) => (
              <div key={item.label} className="presence-row">
                <span className="presence-label">{item.label}</span>
                <div className="presence-bar-track">
                  <div
                    className="presence-bar-fill"
                    style={{ width: `${item.value}%`, background: item.color }}
                  />
                </div>
                <span className="presence-value">{item.value}</span>
              </div>
            ))}
          </div>

          <div style={{
            marginTop: 'var(--space-lg)',
            padding: 'var(--space-md)',
            background: 'rgba(129, 140, 248, 0.06)',
            borderRadius: 'var(--radius-sm)',
            border: '1px solid rgba(129, 140, 248, 0.12)',
            fontSize: 'var(--font-size-xs)',
            color: 'var(--text-secondary)',
            lineHeight: 1.6,
          }}>
            💡 <strong style={{ color: 'var(--accent-primary)' }}>Dato clave:</strong> El 43% de los platos
            de la carta son aptos para comensales con los 4 alérgenos más frecuentes
            (Gluten, Lácteos, Huevos, Frutos de cáscara).
          </div>
        </Panel>
      </div>

      {/* ═══════════════════════════════════════════════════════════════
          SECCIÓN 4: Alternativas Sugeridas + Historial de Alertas
          Utilidad para camareros: Saber qué recomendar cuando un
          comensal declara una alergia
          ═══════════════════════════════════════════════════════════════ */}
      <div className="section-title-row">
        <span className="section-title-text">Gestión Operativa</span>
      </div>

      <div className="panels-row">
        {/* Panel izquierdo: Alternativas */}
        <Panel
          title="Alternativas Sugeridas"
          icon="🔄"
          subtitle="Recomendaciones automáticas para platos con alérgenos"
        >
          <div className="alternatives-list">
            {alternatives.map((alt, i) => (
              <div key={i} className="alternative-card">
                <div className="alternative-original">
                  <div className="alternative-original-name">{alt.original}</div>
                  <div className="alternative-original-allergens">
                    {alt.originalAllergens.map((a) => (
                      <span key={a} className="badge badge-danger">{a}</span>
                    ))}
                  </div>
                </div>
                <span className="alternative-arrow">→</span>
                <div className="alternative-replacement">
                  <div className="alternative-replacement-name">✅ {alt.replacement}</div>
                  <div className="alternative-replacement-reason">{alt.reason}</div>
                </div>
              </div>
            ))}
          </div>
        </Panel>

        {/* Panel derecho: Historial de alertas */}
        <Panel
          title="Historial de Alertas"
          icon="📜"
          subtitle="Últimos 7 días"
        >
          <table className="panel-table">
            <thead>
              <tr>
                <th>Fecha</th>
                <th>Comensal</th>
                <th>Alérgeno</th>
                <th>Mesa</th>
                <th>Estado</th>
              </tr>
            </thead>
            <tbody>
              {recentAlerts.map((alert) => (
                <tr key={alert.id}>
                  <td>
                    <div style={{ fontVariantNumeric: 'tabular-nums' }}>{alert.time}</div>
                    <div style={{ fontSize: 'var(--font-size-xs)', color: 'var(--text-muted)' }}>
                      {alert.date}
                    </div>
                  </td>
                  <td>{alert.comensal}</td>
                  <td>
                    <span className={`badge ${
                      alert.severity === 'alta' ? 'badge-danger' :
                      alert.severity === 'media' ? 'badge-warning' : 'badge-info'
                    }`}>
                      {alert.allergen}
                    </span>
                  </td>
                  <td style={{ color: 'var(--text-secondary)' }}>{alert.table}</td>
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
      </div>
    </div>
  )
}

export default AllergensPage
