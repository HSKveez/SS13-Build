import { classes } from 'common/react';
import { capitalizeAll } from 'common/string';
import { useBackend, useLocalState } from 'tgui/backend';
import { Box, Button, Icon, LabeledList, NoticeBox, Section, Stack, Table } from 'tgui/components';
import { Window } from 'tgui/layouts';

type VendingData = {
  onstation: boolean;
  department: string;
  jobDiscount: number;
  product_records: ProductRecord[];
  coin_records: CoinRecord[];
  hidden_records: HiddenRecord[];
  user: UserData;
  stock: StockItem[];
  extended_inventory: boolean;
  access: boolean;
  vending_machine_input: CustomInput[];
  categories: Record<string, Category>;
};

type Category = {
  icon: string;
};

type ProductRecord = {
  path: string;
  name: string;
  price: number;
  max_amount: number;
  ref: string;
  category: string;
};

type CoinRecord = ProductRecord & {
  premium: boolean;
};

type HiddenRecord = ProductRecord & {
  premium: boolean;
};

type UserData = {
  name: string;
  cash: number;
  job: string;
  department: string;
};

type StockItem = {
  name: string;
  amount: number;
  colorable: boolean;
};

type CustomInput = {
  name: string;
  price: number;
  img: string;
};

export const Vending = (props, context) => {
  const { data } = useBackend<VendingData>(context);

  const {
    onstation,
    product_records = [],
    coin_records = [],
    hidden_records = [],
    stock,
  } = data;

  const [selectedCategory, setSelectedCategory] = useLocalState<string>(
    context,
    'selectedCategory',
    Object.keys(data.categories)[0]
  );

  let inventory: (ProductRecord | CustomInput)[];
  let custom = false;
  if (data.vending_machine_input) {
    inventory = data.vending_machine_input;
    custom = true;
  } else {
    inventory = [...product_records, ...coin_records];
    if (data.extended_inventory) {
      inventory = [...inventory, ...hidden_records];
    }
  }

  inventory = inventory
    // Just in case we still have undefined values in the list
    .filter((item) => !!item);

  const filteredCategories = Object.fromEntries(
    Object.entries(data.categories).filter(([categoryName]) => {
      return inventory.find((product) => {
        if ('category' in product) {
          return product.category === categoryName;
        } else {
          return false;
        }
      });
    })
  );

  return (
    <Window width={450} height={600}>
      <Window.Content>
        <Stack fill vertical>
          {!!onstation && (
            <Stack.Item>
              <UserDetails />
            </Stack.Item>
          )}
          <Stack.Item grow>
            <ProductDisplay
              custom={custom}
              inventory={inventory}
              selectedCategory={selectedCategory}
            />
          </Stack.Item>

          {Object.keys(filteredCategories).length > 1 && (
            <Stack.Item>
              <CategorySelector
                categories={filteredCategories}
                selectedCategory={selectedCategory!}
                onSelect={setSelectedCategory}
              />
            </Stack.Item>
          )}
        </Stack>
      </Window.Content>
    </Window>
  );
};

/** Displays user details if an ID is present and the user is on the station */
export const UserDetails = (props, context) => {
  const { data } = useBackend<VendingData>(context);
  const { user } = data;

  if (!user) {
    return (
      <NoticeBox>Нет ID-карты! Свяжитесь с местным отделом кадров!</NoticeBox>
    );
  } else {
    return (
      <Section>
        <Stack>
          <Stack.Item>
            <Icon name="id-card" size={3} mr={1} />
          </Stack.Item>
          <Stack.Item>
            <LabeledList>
              <LabeledList.Item label="Пользователь">{user.name}</LabeledList.Item>
              <LabeledList.Item label="Должность">
                {user.job || 'Безработный'}
              </LabeledList.Item>
            </LabeledList>
          </Stack.Item>
        </Stack>
      </Section>
    );
  }
};

/** Displays  products in a section, with user balance at top */
const ProductDisplay = (
  props: {
    custom: boolean;
    selectedCategory: string | null;
    inventory: (ProductRecord | CustomInput)[];
  },
  context
) => {
  const { data } = useBackend<VendingData>(context);
  const { custom, inventory, selectedCategory } = props;
  const { stock, onstation, user } = data;

  return (
    <Section
      fill
      scrollable
      title="Товары"
      buttons={
        !!onstation &&
        user && (
          <Box fontSize="16px" color="green">
            {(user && user.cash) || 0} кр <Icon name="coins" color="gold" />
          </Box>
        )
      }>
      <Table>
        {inventory
          .filter((product) => {
            if ('category' in product) {
              return product.category === selectedCategory;
            } else {
              return true;
            }
          })
          .map((product) => (
            <VendingRow
              key={product.name}
              custom={custom}
              product={product}
              productStock={stock[product.name]}
            />
          ))}
      </Table>
    </Section>
  );
};

/** An individual listing for an item.
 * Uses a table layout. Labeledlist might be better,
 * but you cannot use item icons as labels currently.
 */
const VendingRow = (props, context) => {
  const { data } = useBackend<VendingData>(context);
  const { custom, product, productStock } = props;
  const { access, department, jobDiscount, onstation, user } = data;
  const free = !onstation || product.price === 0;
  const discount = !product.premium && department === user?.department;
  const remaining = custom ? product.amount : productStock.amount;
  const redPrice = Math.round(product.price * jobDiscount);
  const disabled =
    remaining === 0 ||
    (onstation && !user) ||
    (onstation &&
      !access &&
      (discount ? redPrice : product.price) > user?.cash);

  return (
    <Table.Row>
      <Table.Cell collapsing>
        <ProductImage product={product} />
      </Table.Cell>
      <Table.Cell bold>{capitalizeAll(product.name)}</Table.Cell>
      <Table.Cell>
        {!!productStock?.colorable && (
          <ProductColorSelect disabled={disabled} product={product} />
        )}
      </Table.Cell>
      <Table.Cell collapsing textAlign="right">
        <ProductStock custom={custom} product={product} remaining={remaining} />
      </Table.Cell>
      <Table.Cell collapsing textAlign="center">
        <ProductButton
          custom={custom}
          disabled={disabled}
          discount={discount}
          free={free}
          product={product}
          redPrice={redPrice}
        />
      </Table.Cell>
    </Table.Row>
  );
};

/** Displays the product image. Displays a default if there is none. */
const ProductImage = (props) => {
  const { product } = props;

  return product.img ? (
    <img
      src={`data:image/jpeg;base64,${product.img}`}
      style={{
        'vertical-align': 'middle',
        'horizontal-align': 'middle',
      }}
    />
  ) : (
    <span
      className={classes(['vending32x32', product.path])}
      style={{
        'vertical-align': 'middle',
        'horizontal-align': 'middle',
      }}
    />
  );
};

/** In the case of customizable items, ie: shoes,
 * this displays a color wheel button that opens another window.
 */
const ProductColorSelect = (props, context) => {
  const { act } = useBackend<VendingData>(context);
  const { disabled, product } = props;

  return (
    <Button
      icon="palette"
      tooltip="Изменить цвет"
      disabled={disabled}
      onClick={() => act('select_colors', { ref: product.ref })}
    />
  );
};

/** Displays a colored indicator for remaining stock */
const ProductStock = (props) => {
  const { custom, product, remaining } = props;

  return (
    <Box
      color={
        (remaining <= 0 && 'bad') ||
        (!custom && remaining <= product.max_amount / 2 && 'average') ||
        'good'
      }>
      {remaining} осталось
    </Box>
  );
};

/** The main button to purchase an item. */
const ProductButton = (props, context) => {
  const { act, data } = useBackend<VendingData>(context);
  const { access } = data;
  const { custom, discount, disabled, free, product, redPrice } = props;
  const customPrice = access ? 'БЕСПЛАТНО' : product.price + ' кр';
  let standardPrice = product.price + ' кр';
  if (free) {
    standardPrice = 'БЕСПЛАТНО';
  } else if (discount) {
    standardPrice = redPrice + ' кр';
  }
  return custom ? (
    <Button
      fluid
      disabled={disabled}
      onClick={() =>
        act('dispense', {
          'item': product.name,
        })
      }>
      {customPrice}
    </Button>
  ) : (
    <Button
      fluid
      disabled={disabled}
      onClick={() =>
        act('vend', {
          'ref': product.ref,
        })
      }>
      {standardPrice}
    </Button>
  );
};

const CATEGORY_COLORS = {
  'Контрабанда': 'red',
  'Премиум': 'yellow',
};

const CategorySelector = (props: {
  categories: Record<string, Category>;
  selectedCategory: string;
  onSelect: (category: string) => void;
}) => {
  const { categories, selectedCategory, onSelect } = props;

  return (
    <Stack grow>
      <Stack.Item>
        {Object.entries(categories).map(([name, category]) => (
          <Button
            key={name}
            selected={name === selectedCategory}
            color={CATEGORY_COLORS[name]}
            icon={category.icon}
            onClick={() => onSelect(name)}>
            {name}
          </Button>
        ))}
      </Stack.Item>
    </Stack>
  );
};