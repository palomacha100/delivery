require 'csv'

class AnalysisController < ApplicationController
  def anacor
    store_id = params[:store_id]
    thirty_days_ago = 30.days.ago

    sales_data = ActiveRecord::Base.connection.execute(
      ActiveRecord::Base.sanitize_sql_array(["
        SELECT 
          p.title AS product,
          strftime('%w', o.created_at) AS day_of_week,
          COUNT(*) AS sales_count
        FROM 
          orders o
        JOIN 
          order_items oi ON o.id = oi.order_id
        JOIN 
          products p ON oi.product_id = p.id
        WHERE 
          o.store_id = ? AND o.created_at >= ?
        GROUP BY 
          p.title, day_of_week
        ORDER BY 
          p.title, day_of_week;", store_id, thirty_days_ago])
    )

    products = sales_data.map { |row| row['product'] }.uniq
    days_of_week = (0..6).to_a.map { |d| Date::DAYNAMES[d.to_i] } # Usando nomes dos dias da semana

    contingency_table = Array.new(products.length) { Array.new(days_of_week.length, 0) }

    sales_data.each do |row|
      product_index = products.index(row['product'])
      day_index = row['day_of_week'].to_i
      contingency_table[product_index][day_index] = row['sales_count'].to_i
    end

    R.assign 'products', products
    R.assign 'days_of_week', days_of_week
    R.assign 'contingency_table', contingency_table.flatten

    R.eval <<-EOF
    library(showtext)
    font_add_google("Poppins", "poppins")
    showtext_auto()

      library(FactoMineR)
      library(ggplot2)
      library(reshape2)

      table_matrix <- matrix(contingency_table, nrow = length(products), byrow = TRUE)
      if (length(days_of_week) == ncol(table_matrix)) {
        colnames(table_matrix) <- days_of_week
      }
      if (length(products) == nrow(table_matrix)) {
        rownames(table_matrix) <- products
      }

      # Executando análise de correspondência
      anacor <- CA(table_matrix, graph = FALSE)
      coord <- anacor$row$coord

      # Preparando dados para o gráfico
      coord_df <- data.frame(Product = products, Dim1 = coord[,1], Dim2 = coord[,2])

      # Gerando o heatmap
      p <- ggplot(data = melt(table_matrix), aes(x = Var2, y = Var1, fill = value)) +
        geom_tile() +
        scale_fill_gradient(low = "#DCDCDC", high = "#2c5c8f") +
        scale_fill_gradient(low = "#DCDCDC", high = "#2c5c8f", 
        guide = guide_colorbar(barwidth = 0.5, barheight = 3, 
        label.theme = element_text(size = 9, family = "poppins"))) +
        labs(x = "Dia da Semana",
             y = "Produto",
             fill = "Vendas") +
        theme_minimal() +
        theme(
          axis.text.x = element_text(angle = 45, hjust = 1, family = "poppins", size = 10, color = "#48484d"),
          axis.text.y = element_text(family = "poppins", size = 12, color = "#48484d"),
          axis.title.x = element_text(family = "poppins", size = 10, color = "#48484d"),
          axis.title.y = element_text(family = "poppins", size = 10, color = "#48484d"),
          plot.title = element_text(family = "poppins", size = 16, hjust = 0.5, color = "#48484d"),
          legend.text = element_text(family = "poppins", size = 12, color = "#48484d"),
          legend.title = element_text(family = "poppins", size = 12, color = "#48484d"),
          panel.background = element_rect(fill = "#fff", color = NA), # Alterando a cor de fundo do mapa
          plot.background = element_rect(fill = "transparent", color = NA), # Alterando a cor de fundo do gráfico
          legend.background = element_rect(fill = "#fff", color = NA) # Alterando a cor de fundo da legenda
        )

      ggsave('/tmp/anacor_plot.png', plot = p, width = 3, height = 2)

      # Salvando as coordenadas em um arquivo CSV
      write.csv(coord_df, '/tmp/coord_df.csv', row.names = FALSE)
    EOF

    public_path = Rails.root.join('public', 'anacor_plot.png')
    FileUtils.mv('/tmp/anacor_plot.png', public_path)

    # Lendo os dados de volta do R
    coord_df = CSV.read('/tmp/coord_df.csv', headers: true)

    # Formatando os dados para resposta JSON
    result = coord_df.map { |row| { product: row['Product'], coordinates: { Dim1: row['Dim1'], Dim2: row['Dim2'] } } }

    render json: { result: result, plot_image: '/anacor_plot.png' }
  end
end



