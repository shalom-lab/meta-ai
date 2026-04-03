library(httr)
library(jsonlite)
library(tidyverse)


# df.1 <- read_csv("Data/Global_health_1_500.csv")

system_prompt <- paste(
  "你是一个专门用于 RSV 儿童流行病学 Meta 分析文献初筛的助手。",
  "请严格遵守以下规则：",
  "1. 保守但不死板：只有当文章明显不相关或不符合纳入标准时才排除。",
  "2. 如果信息不足但可能符合条件，请不要排除（exclude=0），并降低 exclude_prob。",
  "3. 输出必须是 JSON：",
  "{\"exclude\": 0_or_1, \"exclude_prob\": 0.0_to_1.0, \"reason\": \"中文简短说明\"}",
  "4. 不要输出 JSON 之外任何内容。",
  "",
  "筛选标准：",
  "- 年龄：≤5岁儿童,如果研究的年龄段包含儿童段的也不应该删除哦",
  "- 必须报告 RSV 发病率/住院率/死亡率，而不是简单的病例数发病数",
  "- 地区：中低收入国家（排除高收入国家），如果是多个地区的，只有全部都是高收入的时候才排除",
  "- 时间：2019年底前（排除新冠后研究），如果完全是新冠后的请排除，包含新冠前的不排除",
  sep = "\n"
)

build_prompt <- function(TI, AB) {
  paste0(
    "标题:\n", TI, "\n\n",
    "摘要:\n", AB, "\n\n",
    "请根据规则判断是否排除。"
  )
}

# qwen-plus-2025-07-28 处理到df.2_7 939
# qwen-plus
# qwen-flash

call_qwen <- function(prompt, api_key, system_prompt) {

  url <- "https://dashscope.aliyuncs.com/api/v1/services/aigc/text-generation/generation"

  res <- POST(
    url,
    add_headers(
      Authorization = paste("Bearer", api_key),
      "Content-Type" = "application/json"
    ),
    body = toJSON(list(
      model = "qwen-flash", # 我试了上面3个模型
      input = list(
        messages = list(
          list(role = "system", content = system_prompt),
          list(role = "user", content = prompt)
        )
      ),
      parameters = list(
        temperature = 0,
        max_tokens = 200
      )
    ), auto_unbox = TRUE)
  )

  content(res, as = "parsed", encoding = "UTF-8")
}

parse_result <- function(x) {
  tryCatch({
    jsonlite::fromJSON(x)
  }, error = function(e) {
    list(exclude = NA, exclude_prob = NA, reason = "解析失败")
  })
}

api_key <- "your api key"


# https://bailian.console.aliyun.com/cn-beijing?tab=api#/api 如何获取APIKEY

# df.1 ----
# df.1$prompt <- map2_chr(df.1$TI, df.1$AB, build_prompt)
# df.1$response <- NA
# df.1$raw_text <- NA
# df.1$exclude <- NA
# df.1$exclude_prob <- NA
# df.1$reason <- NA

for (i in 1:nrow(df.1)) {
  cat("Processing row:", i, "\n")
  if (!is.na(df.1$raw_text[i])) {
    next
  }
  tryCatch({
    res <- call_qwen(df.1$prompt[i], api_key, system_prompt)
    if (!is.null(res$output$text)) {
      df.1$raw_text[i] <- res$output$text
      parsed <- parse_result(res$output$text)
      df.1$exclude[i] <- parsed$exclude
      df.1$exclude_prob[i] <- parsed$exclude_prob
      df.1$reason[i] <- parsed$reason
    } else {
      cat("⚠️ No response at row:", i, "\n")
    }
  }, error = function(e) {
    cat("❌ Error at row:", i, "\n")
  })
}

# 501-3362 ----

# df.2_7<-dir('Data/',pattern = 'Global_health',full.names = T)[c(7,2,3,4,5,6)] %>%
#   map_dfr(~read_csv(.x) %>% mutate(across(everything(),as.character))) %>%
#   mutate(prompt=map2_chr(TI,AB, build_prompt),
#          response=NA_real_,
#          raw_text=NA_real_,
#          exclude=NA_real_,
#          exclude_prob=NA_real_,
#          reason=NA_real_)

head(df.2_7)
for (i in 1:nrow(df.2_7)) {
  cat("Processing row:", i, "\n")
  if (!is.na(df.2_7$raw_text[i])) {
    next
  }
  tryCatch({
    res <- call_qwen(df.2_7$prompt[i], api_key, system_prompt)
    if (!is.null(res$output$text)) {
      df.2_7$raw_text[i] <- res$output$text
      parsed <- parse_result(res$output$text)
      df.2_7$exclude[i] <- parsed$exclude
      df.2_7$exclude_prob[i] <- parsed$exclude_prob
      df.2_7$reason[i] <- parsed$reason
    } else {
      cat("⚠️ No response at row:", i, "\n")
    }
  }, error = function(e) {
    cat("❌ Error at row:", i, "\n")
  })
}


save.image('rda/code.RData')

write.csv(df.1,'rda/df.1.csv')
write.csv(df.2_7,'rda/df.2_7.csv')

df.3362<-bind_rows(df.1 %>%
            mutate(across(TY:SE,as.character)),df.2_7)

df.3362 %>%
  mutate(.group = (row_number() - 1) %/% 500) %>%
  group_split(.group) %>%
  iwalk(~ {
    .x <- select(.x, -.group)  # 防止写入分组列

    start_row <- (.y - 1) * 500 + 1
    end_row <- start_row + nrow(.x) - 1

    file_path <- sprintf("rda/df.3362_%d_%d.csv", start_row, end_row)

    write_excel_csv(.x, file_path)

    cat("已保存第", .y, "组 ->", file_path, "\n")
  })

# Reason category ----
df_1862<-dir('rda',pattern = 'df.3362.*.csv',full.names = T)[c(3,4,5,6)] %>%
  map_dfr(~read_csv(.x) %>% mutate(across(TY:SE,as.character))) %>%
  mutate(is_HIC=str_detect(reason,'高收入国家'),
         is_animal=str_detect(reason,'(牛|动物)'),
         is_adult=str_detect(reason,'(成人|成年人|老年人|老人)'),
         is_postcovid=str_detect(reason,'(新冠后)')) %>%
  mutate(type=case_when(is_HIC~'HIC',
                        is_animal~'animal',
                        is_adult~'adult',
                        is_postcovid~'postcovid',
                        T~'other'))

df_1862 %>% count(type)

split(df_1862,df_1862$type) %>%
  iwalk(~{
    write_excel_csv(.x,paste0('rda/df_1862_',.y,'_',nrow(.x),'.csv'))
  })

# Code after checked ----
df_checked<-dir('人工核查',pattern = 'checked',full.names = T) %>%
  map_dfr(~read_csv(.x) %>% mutate(across(TY:SE,as.character)))

df_checked %>% count(exclude)

c(exclude=1,keep=0,all='0|1') %>%
  iwalk(~{
    df_sub <- df_checked %>%
      filter(str_detect(as.character(exclude), .x))

    rio::export(df_sub,sprintf('人工核查/df_che_3362_%s_%s.csv',.y,nrow(df_sub)))
  })
