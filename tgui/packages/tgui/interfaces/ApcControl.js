import { map, sortBy } from 'common/collections';
import { flow } from 'common/fp';
import { pureComponentHooks } from 'common/react';
import { useBackend, useLocalState } from '../backend';
import { Box, Button, Dimmer, Icon, Table, Tabs, Stack, Section } from '../components';
import { Window } from '../layouts';
import { AreaCharge, powerRank } from './PowerMonitor';

export const ApcControl = (props, context) => {
  const { data } = useBackend(context);
  return (
    <Window title="Контроллер энергии" width={550} height={500}>
      <Window.Content>
        {data.authenticated === 1 && <ApcLoggedIn />}
        {data.authenticated === 0 && <ApcLoggedOut />}
      </Window.Content>
    </Window>
  );
};

const ApcLoggedOut = (props, context) => {
  const { act, data } = useBackend(context);
  const { emagged } = data;
  const text = emagged === 1 ? 'Открыть' : 'Войти';
  return (
    <Section>
      <Button
        icon="sign-in-alt"
        color={emagged === 1 ? '' : 'good'}
        content={text}
        fluid
        onClick={() => act('log-in')}
      />
    </Section>
  );
};

const ApcLoggedIn = (props, context) => {
  const { act, data } = useBackend(context);
  const { restoring } = data;
  const [tabIndex, setTabIndex] = useLocalState(context, 'tab-index', 1);
  return (
    <Box>
      <Tabs>
        <Tabs.Tab
          selected={tabIndex === 1}
          onClick={() => {
            setTabIndex(1);
            act('check-apcs');
          }}>
          Управление питанием
        </Tabs.Tab>
        <Tabs.Tab
          selected={tabIndex === 2}
          onClick={() => {
            setTabIndex(2);
            act('check-logs');
          }}>
          Панель журналов
        </Tabs.Tab>
      </Tabs>
      {restoring === 1 && (
        <Dimmer fontSize="32px">
          <Icon name="cog" spin />
          {' Сброс...'}
        </Dimmer>
      )}
      {tabIndex === 1 && (
        <Stack vertical>
          <Stack.Item>
            <Section>
              <ControlPanel />
            </Section>
          </Stack.Item>
          <Stack.Item>
            <Section scrollable>
              <ApcControlScene />
            </Section>
          </Stack.Item>
        </Stack>
      )}
      {tabIndex === 2 && (
        <Section scrollable>
          <Box height={34}>
            <LogPanel />
          </Box>
        </Section>
      )}
    </Box>
  );
};

const ControlPanel = (props, context) => {
  const { act, data } = useBackend(context);
  const { emagged, logging } = data;
  const [sortByField, setSortByField] = useLocalState(
    context,
    'sortByField',
    'name'
  );
  return (
    <Stack justify="space-between">
      <Stack.Item>
        <Box inline mr={2} color="label">
          Сортировка:
        </Box>
        <Button.Checkbox
          checked={sortByField === 'name'}
          content="Имя"
          onClick={() => setSortByField(sortByField !== 'name' && 'name')}
        />
        <Button.Checkbox
          checked={sortByField === 'charge'}
          content="Заряд"
          onClick={() => setSortByField(sortByField !== 'charge' && 'charge')}
        />
        <Button.Checkbox
          checked={sortByField === 'draw'}
          content="Потребление"
          onClick={() => setSortByField(sortByField !== 'draw' && 'draw')}
        />
      </Stack.Item>
      <Stack.Item grow={1} />
      <Stack.Item>
        {emagged === 1 && (
          <>
            <Button
              color={logging === 1 ? 'bad' : 'good'}
              content={logging === 1 ? 'Остановить запись' : 'Продолжить запись'}
              onClick={() => act('toggle-logs')}
            />
            <Button
              content="Сбросить консоль"
              onClick={() => act('restore-console')}
            />
          </>
        )}
        <Button
          icon="sign-out-alt"
          color="bad"
          content="Выйти"
          onClick={() => act('log-out')}
        />
      </Stack.Item>
    </Stack>
  );
};

const ApcControlScene = (props, context) => {
  const { data, act } = useBackend(context);

  const [sortByField] = useLocalState(context, 'sortByField', 'name');

  const apcs = flow([
    map((apc, i) => ({
      ...apc,
      // Generate a unique id
      id: apc.name + i,
    })),
    sortByField === 'name' && sortBy((apc) => apc.name),
    sortByField === 'charge' && sortBy((apc) => -apc.charge),
    sortByField === 'draw' &&
      sortBy(
        (apc) => -powerRank(apc.load),
        (apc) => -parseFloat(apc.load)
      ),
  ])(data.apcs);
  return (
    <Box height={30}>
      <Table>
        <Table.Row header>
          <Table.Cell>Вкл/Выкл</Table.Cell>
          <Table.Cell>Зона</Table.Cell>
          <Table.Cell collapsing>Заряд</Table.Cell>
          <Table.Cell collapsing textAlign="right">
            Потребление
          </Table.Cell>
          <Table.Cell collapsing title="Оборудование">
            Обр
          </Table.Cell>
          <Table.Cell collapsing title="Освещение">
            Свт
          </Table.Cell>
          <Table.Cell collapsing title="Окружение">
            Окр
          </Table.Cell>
        </Table.Row>
        {apcs.map((apc, i) => (
          <tr key={apc.id} className="Table__row  candystripe">
            <td>
              <Button
                icon={apc.operating ? 'power-off' : 'times'}
                color={apc.operating ? 'good' : 'bad'}
                onClick={() =>
                  act('breaker', {
                    ref: apc.ref,
                  })
                }
              />
            </td>
            <td>
              <Button
                onClick={() =>
                  act('access-apc', {
                    ref: apc.ref,
                  })
                }>
                {apc.name}
              </Button>
            </td>
            <td className="Table__cell text-right text-nowrap">
              <AreaCharge charging={apc.charging} charge={apc.charge} />
            </td>
            <td className="Table__cell text-right text-nowrap">{apc.load}</td>
            <td className="Table__cell text-center text-nowrap">
              <AreaStatusColorButton
                target="equipment"
                status={apc.eqp}
                apc={apc}
                act={act}
              />
            </td>
            <td className="Table__cell text-center text-nowrap">
              <AreaStatusColorButton
                target="lighting"
                status={apc.lgt}
                apc={apc}
                act={act}
              />
            </td>
            <td className="Table__cell text-center text-nowrap">
              <AreaStatusColorButton
                target="environ"
                status={apc.env}
                apc={apc}
                act={act}
              />
            </td>
          </tr>
        ))}
      </Table>
    </Box>
  );
};

const LogPanel = (props, context) => {
  const { data } = useBackend(context);

  const logs = flow([
    map((line, i) => ({
      ...line,
      // Generate a unique id
      id: line.entry + i,
    })),
    (logs) => logs.reverse(),
  ])(data.logs);
  return (
    <Box m={-0.5}>
      {logs.map((line) => (
        <Box p={0.5} key={line.id} className="candystripe" bold>
          {line.entry}
        </Box>
      ))}
    </Box>
  );
};

const AreaStatusColorButton = (props) => {
  const { target, status, apc, act } = props;
  const power = Boolean(status & 2);
  const mode = Boolean(status & 1);
  return (
    <Button
      icon={mode ? 'sync' : 'power-off'}
      color={power ? 'good' : 'bad'}
      onClick={() =>
        act('toggle-minor', {
          type: target,
          value: statusChange(status),
          ref: apc.ref,
        })
      }
    />
  );
};

const statusChange = (status) => {
  // mode flip power flip both flip
  // 0, 2, 3
  return status === 0 ? 2 : status === 2 ? 3 : 0;
};

AreaStatusColorButton.defaultHooks = pureComponentHooks;