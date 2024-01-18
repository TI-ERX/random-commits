#!/usr/bin/env sh

_() {
  YEAR="2017"
  echo "GitHub Username: "
  read -r USERNAME
  echo "GitHub Access token: "
  read -r ACCESS_TOKEN

  [ -z "$USERNAME" ] && exit 1
  [ -z "$ACCESS_TOKEN" ] && exit 1
  [ ! -d $YEAR ] && mkdir $YEAR

  cd "${YEAR}" || exit
  git init
  git config core.autocrlf false  # Desativa a conversão automática de CRLF no Windows
  echo "**${YEAR}** - Gerado por https://github.com/TI-ERX/script-several-commits" \
    >README.md
  git add README.md

  # Gera commits aleatórios para todos os dias do ano
  for MONTH in {01..12}
  do
    for DAY in {01..31}
    do
      # Verifica se o dia é válido para o mês
      if [ $DAY -le $(cal $MONTH $YEAR | awk 'NF {DAYS = $NF} END {print DAYS}') ]; then
        # Verifica se o dia é um sábado ou domingo (dias 6 e 0 no formato ISO, onde segunda é 1)
        if [ "$(date -d "${YEAR}-${MONTH}-${DAY}" +%u)" -ge 6 ]; then
          continue  # Pula para o próximo dia se for sábado ou domingo
        fi

        # Gera um número aleatório entre 0 e 1
        RANDOM_NUMBER=$(($RANDOM % 2))

        # Decide aleatoriamente se deve haver um commit para este dia
        if [ $RANDOM_NUMBER -eq 1 ]; then
          echo "Conteúdo para ${YEAR}-${MONTH}-${DAY}" > "day${DAY}_month${MONTH}.txt"
          git add "day${DAY}_month${MONTH}.txt"

          # Gera horas aleatórias entre 12:00 e 23:59
          RANDOM_HOUR=$((12 + RANDOM % 12))
          RANDOM_MINUTE=$((RANDOM % 60))
          GIT_AUTHOR_DATE="${YEAR}-${MONTH}-${DAY}T${RANDOM_HOUR}:${RANDOM_MINUTE}:00" \
            GIT_COMMITTER_DATE="${YEAR}-${MONTH}-${DAY}T${RANDOM_HOUR}:${RANDOM_MINUTE}:00" \
            git commit -m "Commit para ${YEAR}-${MONTH}-${DAY}"
        fi
      fi
    done
  done

  git remote add origin "https://${ACCESS_TOKEN}@github.com/${USERNAME}/${YEAR}.git"
  git branch -M main
  git push -u origin main -f
  cd ..
  rm -rf "${YEAR}"

  echo
  echo "Pronto, agora verifique seu perfil: https://github.com/${USERNAME}"
} && _

unset -f _
